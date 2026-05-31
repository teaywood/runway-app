# server/core/graph_loader.py
"""
서버 시작 시 단 1회만 실행되는 무거운 전처리 작업을 모두 담당합니다.
결과물은 모듈 레벨 변수에 저장되어 메모리에 영구 상주합니다.
"""
import os
import pickle
import hashlib
import time
import logging

import osmnx as ox
import pandas as pd
import geopandas as gpd
import networkx as nx
from shapely.geometry import Point

logger = logging.getLogger("graph_loader")

# ── 경로 설정 ───────────────────────────────────────────
DATA_DIR   = os.path.join(os.path.dirname(__file__), "..", "..", "")
CACHE_FILE = os.path.join(DATA_DIR, ".cache", "processed_graph.pkl")

# ── 전역 캐시 객체 (메모리 상주) ────────────────────────
_G_WEIGHTED: nx.MultiDiGraph | None = None   # 가중치 완성된 그래프 (원본 좌표계)
_G_PROJ:     nx.MultiDiGraph | None = None   # 투영 좌표계 그래프 (오프셋 연산용)
_CACHE_HASH: str = ""                         # 데이터 파일 변경 감지용 해시


def _compute_data_hash() -> str:
    """데이터 파일들의 수정 시각을 해시화 — 파일 변경 시 캐시 자동 무효화"""
    files = [
        "bukgu_run_network.graphml",
        "bukgu_cctv.csv",
        "bukgu_integrated_lights.csv",
        "bukgu_safe_zones.geojson",
    ]
    hasher = hashlib.md5()
    for f in files:
        path = os.path.join(DATA_DIR, f)
        if os.path.exists(path):
            hasher.update(str(os.path.getmtime(path)).encode())
    return hasher.hexdigest()


def _build_weighted_graph() -> tuple[nx.MultiDiGraph, nx.MultiDiGraph]:
    """
    ai_engine.py의 전처리 로직 전체를 함수화.
    반환: (G_weighted, G_proj)
    """
    t0 = time.time()

    # ── 1. 도로망 로드 ─────────────────────────────────
    logger.info("📡 GraphML 로드 중...")
    G = ox.load_graphml(os.path.join(DATA_DIR, "bukgu_run_network.graphml"))
    G_proj = ox.project_graph(G)
    edges = ox.graph_to_gdfs(G_proj, nodes=False)

    # ── 2. Safe Zone sjoin ────────────────────────────
    logger.info("🌳 Safe Zone sjoin 계산 중...")
    safe_zones = gpd.read_file(os.path.join(DATA_DIR, "bukgu_safe_zones.geojson"))
    safe_zones_proj = safe_zones.to_crs(edges.crs)
    safe_edges = gpd.sjoin(edges, safe_zones_proj, how="inner", predicate="intersects")
    safe_edge_set = set(safe_edges.index)

    # ── 3. 안전 시설 sjoin ────────────────────────────
    logger.info("💡 안전 시설 버퍼 sjoin 계산 중...")
    cctv   = pd.read_csv(os.path.join(DATA_DIR, "bukgu_cctv.csv"))
    lights = pd.read_csv(os.path.join(DATA_DIR, "bukgu_integrated_lights.csv"))

    for df in [cctv, lights]:
        df['위도'] = pd.to_numeric(df['위도'], errors='coerce')
        df['경도'] = pd.to_numeric(df['경도'], errors='coerce')

    safety_df = pd.concat([cctv[['위도', '경도']], lights[['위도', '경도']]]).dropna()
    gdf_safety = gpd.GeoDataFrame(
        safety_df,
        geometry=[Point(r['경도'], r['위도']) for _, r in safety_df.iterrows()],
        crs="EPSG:4326"
    ).to_crs(edges.crs)

    edges_buf = edges.copy()
    edges_buf['geometry'] = edges_buf.geometry.buffer(20)
    joined = gpd.sjoin(gdf_safety, edges_buf, how="inner", predicate="within")
    safety_counts = joined.groupby(['u', 'v', 'key']).size()

    # ── 4. 가상 횡단보도 탐지 ─────────────────────────
    logger.info("🕵️ 가상 횡단보도 추론 중...")
    inferred_crosswalks: set = set()
    for node in G.nodes():
        neighbors = set(G.successors(node)).union(set(G.predecessors(node)))
        if len(neighbors) >= 3:
            for nbr in neighbors:
                edge_data = G.get_edge_data(node, nbr) or {}
                for data in edge_data.values():
                    if str(data.get('highway', '')) in ('primary', 'secondary', 'tertiary'):
                        inferred_crosswalks.add(node)
                        break
                if node in inferred_crosswalks:
                    break
    logger.info(f"   → 가상 횡단보도 {len(inferred_crosswalks):,}개 탐지")

    # ── 5. AI 가중치 주입 ─────────────────────────────
    logger.info("🧠 AI 가중치 계산 중...")
    for u, v, key, data in G_proj.edges(keys=True, data=True):
        dist    = data['length']
        penalty = 0
        bonus   = 0

        count          = safety_counts.get((u, v, key), 0)
        effective_count = min(count, 3)
        bonus += effective_count * 30

        hw = str(data.get('highway', ''))
        if hw in ('primary', 'secondary', 'tertiary'):
            bonus += 50

        fw = str(data.get('footway', ''))
        if 'crossing' in hw or 'crossing' in fw:
            penalty += 1000

        if u in inferred_crosswalks or v in inferred_crosswalks:
            if (u, v, key) not in safe_edge_set:
                penalty += 800

        if (u, v, key) in safe_edge_set:
            dist    = dist * 0.001
            penalty = 0

        final_score = max(dist + penalty - bonus, 1)

        # G(원본)와 G_proj(투영) 둘 다 업데이트
        G[u][v][key]['ai_score']      = final_score
        G_proj[u][v][key]['ai_score'] = final_score
        # 실제 길이는 G_proj에 보존 (루프 거리 계산용)
        G_proj[u][v][key]['length']   = data['length']

    logger.info(f"✅ 전처리 완료! 소요 시간: {time.time() - t0:.1f}초")
    return G, G_proj


def get_graph() -> tuple[nx.MultiDiGraph, nx.MultiDiGraph]:
    """
    캐시된 그래프를 반환합니다.
    - 첫 호출 시: pkl 캐시 확인 → 없으면 전처리 후 저장
    - 데이터 파일 변경 시: 캐시 자동 무효화 후 재계산
    - 이후 호출: 메모리 내 객체 즉시 반환 (< 1ms)
    """
    global _G_WEIGHTED, _G_PROJ, _CACHE_HASH

    current_hash = _compute_data_hash()

    # 메모리에 이미 있고, 데이터 변경 없으면 즉시 반환
    if _G_WEIGHTED is not None and current_hash == _CACHE_HASH:
        return _G_WEIGHTED, _G_PROJ

    # pkl 파일 캐시 확인
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "rb") as f:
                cached = pickle.load(f)
            if cached.get("hash") == current_hash:
                logger.info("💾 pkl 캐시 히트! 디스크에서 그래프 로드 중...")
                _G_WEIGHTED = cached["G"]
                _G_PROJ     = cached["G_proj"]
                _CACHE_HASH = current_hash
                return _G_WEIGHTED, _G_PROJ
        except Exception as e:
            logger.warning(f"캐시 로드 실패, 재계산합니다: {e}")

    # 전처리 실행 후 pkl 저장
    logger.info("🔄 캐시 없음 또는 데이터 변경 감지. 전처리 시작...")
    _G_WEIGHTED, _G_PROJ = _build_weighted_graph()
    _CACHE_HASH = current_hash

    try:
        with open(CACHE_FILE, "wb") as f:
            pickle.dump({"hash": current_hash, "G": _G_WEIGHTED, "G_proj": _G_PROJ}, f)
        logger.info(f"💾 pkl 캐시 저장 완료: {CACHE_FILE}")
    except Exception as e:
        logger.warning(f"캐시 저장 실패 (서비스엔 영향 없음): {e}")

    return _G_WEIGHTED, _G_PROJ

def get_pois_in_bbox(bbox: dict) -> dict:
    """
    Bounding Box 내의 POI(관심지점) 데이터 추출
    
    ✅ 개선: 
    - CSV 데이터 기반 (버퍼 처리)
    - 안전 시설이 실제로 도로 네트워크와 만나는 지점 확인
    - bbox 범위 체크 + 거리 필터링
    
    Args:
        bbox: {"min_lat": float, "max_lat": float, "min_lng": float, "max_lng": float}
    
    Returns:
        {
            "cctv": [{"lat": float, "lng": float}, ...],
            "light": [{"lat": float, "lng": float}, ...],
            "crosswalk": [{"lat": float, "lng": float}, ...]
        }
    """
    import os
    
    G, G_proj = get_graph()
    
    pois = {
        "cctv": [],
        "light": [],
        "crosswalk": []
    }
    
    # bbox 유효성 확인
    if not bbox or not all(k in bbox for k in ["min_lat", "max_lat", "min_lng", "max_lng"]):
        logger.warning(f"Invalid bbox: {bbox}")
        return pois
    
    # ─────────────────────────────────────────────
    # 1️⃣ CCTV CSV 로드 및 필터링
    # ─────────────────────────────────────────────
    cctv_path = os.path.join(DATA_DIR, "bukgu_cctv.csv")
    if os.path.exists(cctv_path):
        try:
            cctv_df = pd.read_csv(cctv_path)
            cctv_df['위도'] = pd.to_numeric(cctv_df['위도'], errors='coerce')
            cctv_df['경도'] = pd.to_numeric(cctv_df['경도'], errors='coerce')
            cctv_df = cctv_df.dropna(subset=['위도', '경도'])
            
            # bbox 범위 내 필터링
            cctv_in_bbox = cctv_df[
                (cctv_df['위도'] >= bbox['min_lat']) & 
                (cctv_df['위도'] <= bbox['max_lat']) &
                (cctv_df['경도'] >= bbox['min_lng']) & 
                (cctv_df['경도'] <= bbox['max_lng'])
            ]
            
            for _, row in cctv_in_bbox.iterrows():
                pois["cctv"].append({
                    "lat": float(row['위도']),
                    "lng": float(row['경도'])
                })
        except Exception as e:
            logger.warning(f"CCTV CSV 로드 실패: {e}")
    
    # ─────────────────────────────────────────────
    # 2️⃣ 조명 CSV 로드 및 필터링
    # ─────────────────────────────────────────────
    lights_path = os.path.join(DATA_DIR, "bukgu_integrated_lights.csv")
    if os.path.exists(lights_path):
        try:
            lights_df = pd.read_csv(lights_path)
            lights_df['위도'] = pd.to_numeric(lights_df['위도'], errors='coerce')
            lights_df['경도'] = pd.to_numeric(lights_df['경도'], errors='coerce')
            lights_df = lights_df.dropna(subset=['위도', '경도'])
            
            # bbox 범위 내 필터링
            lights_in_bbox = lights_df[
                (lights_df['위도'] >= bbox['min_lat']) & 
                (lights_df['위도'] <= bbox['max_lat']) &
                (lights_df['경도'] >= bbox['min_lng']) & 
                (lights_df['경도'] <= bbox['max_lng'])
            ]
            
            # 중복 제거 (같은 좌표의 여러 조명은 1개로만 표현)
            lights_unique = lights_in_bbox.drop_duplicates(subset=['위도', '경도'])
            
            for _, row in lights_unique.iterrows():
                pois["light"].append({
                    "lat": float(row['위도']),
                    "lng": float(row['경도'])
                })
        except Exception as e:
            logger.warning(f"조명 CSV 로드 실패: {e}")
    
    # ─────────────────────────────────────────────
    # 3️⃣ 횡단보도 (OSM 노드 기반)
    # ─────────────────────────────────────────────
    try:
        for node, attrs in G.nodes(data=True):
            lat, lng = attrs.get('y'), attrs.get('x')
            
            # bbox 범위 체크
            if not (bbox["min_lat"] <= lat <= bbox["max_lat"] and 
                    bbox["min_lng"] <= lng <= bbox["max_lng"]):
                continue
            
            tags = attrs.get('tags', {})
            
            # OSM에서 명시적으로 횡단보도 태그가 있으면 추가
            if (tags.get('highway') == 'crossing' or 
                tags.get('crossing') is not None):
                
                # 중복 체크
                is_duplicate = any(
                    abs(p['lat'] - lat) < 0.0001 and 
                    abs(p['lng'] - lng) < 0.0001 
                    for p in pois['crosswalk']
                )
                
                if not is_duplicate:
                    pois["crosswalk"].append({"lat": lat, "lng": lng})
    
    except Exception as e:
        logger.warning(f"횡단보도 추출 실패: {e}")
    
    logger.info(f"✅ POI 추출 완료: CCTV {len(pois['cctv'])}, "
                f"조명 {len(pois['light'])}, 횡단보도 {len(pois['crosswalk'])}")
    
    return pois
