# server/core/route_engine.py
"""
🏃 경로 탐색 알고리즘 및 오프셋 처리 로직 (개선 v2.0)
graph_loader에서 받은 그래프를 사용하여 경로를 계산합니다.

[주요 개선사항]
✅ 이슈 1: 보우타이 꼬임 & 360도 회전 해결
   - Edge-by-Edge → Unified LineString 스무딩 + Round join_style
   - 단방향 → 양방향 페널티로 U턴 완전 차단

✅ 이슈 2: 루프 다변화
   - 단일 앵커 → 트라이앵글 웨이포인트 (0°, 120°, 240°)
   - 구간별 누적 페널티로 경로 겹침 원천 차단
"""

import numpy as np
import networkx as nx
import osmnx as ox
import geopandas as gpd
import math
from shapely.geometry import LineString, mapping, Point
from typing import Optional, Tuple, Set, Dict, List




# ════════════════════════════════════════════════════════
# 📊 로깅 유틸
# ════════════════════════════════════════════════════════

class RouteLogger:
    """경로 계산 과정을 추적하는 로거"""
    
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        self.logs = []
    
    def debug(self, msg: str):
        if self.verbose:
            print(f"[DEBUG] {msg}")
        self.logs.append(("DEBUG", msg))
    
    def info(self, msg: str):
        if self.verbose:
            print(f"[INFO]  {msg}")
        self.logs.append(("INFO", msg))
    
    def warn(self, msg: str):
        if self.verbose:
            print(f"[WARN]  ⚠️ {msg}")
        self.logs.append(("WARN", msg))
    
    def error(self, msg: str):
        if self.verbose:
            print(f"[ERROR] ❌ {msg}")
        self.logs.append(("ERROR", msg))


logger = RouteLogger(verbose=True)


# ════════════════════════════════════════════════════════
# 🔧 Part 1: 통짜 스무딩 & 오프셋 (이슈 1-1 해결)
# ════════════════════════════════════════════════════════

def _smooth_and_offset_unified_linestring(
    line: LineString,
    offset_m: float = -4.5,
    simplify_tolerance: float = 0.5
) -> LineString:
    """
    경로 전체를 하나의 LineString으로 통합한 후 
    스무딩 + 오프셋을 한 번에 적용합니다.
    
    Shapely 2.0+ 호환 버전
    """
    if line.length < 1.0:
        logger.warn(f"경로 길이가 1m 미만 ({line.length:.2f}m), 원본 반환")
        return line
    
    try:
        # 1️⃣ Simplify: 미세한 떨림 제거
        logger.debug(f"Simplify 시작 (tolerance={simplify_tolerance}m)")
        # ✅ 메소드 호출로 변경
        simplified = line.simplify(tolerance=simplify_tolerance)
        
        if simplified.is_empty:
            logger.warn("Simplify 결과 empty, 원본 반환")
            return line
        
        if len(list(simplified.coords)) < 2:
            logger.warn("Simplify 결과 좌표 2개 미만, 원본 반환")
            return line
        
        logger.info(f"✅ Simplify 완료: {len(list(line.coords))} → {len(list(simplified.coords))} 점")
        
        # 2️⃣ Buffer: Round join_style로 부드러운 오프셋
        if abs(offset_m) < 0.1:
            logger.info("오프셋 값이 무시할 수준이므로 원본 반환")
            return simplified
        
        logger.debug(f"Buffer 시작 (offset={offset_m}m, join_style=Round)")
        
        buffered = simplified.buffer(
            distance=-abs(offset_m),
            resolution=16,
            join_style=1
        )
        
        if buffered.is_empty:
            logger.warn("Buffer 결과 empty, simplified 반환")
            return simplified
        
        if buffered.geom_type == 'Polygon':
            result = LineString(buffered.exterior.coords)
            logger.info(f"✅ Buffer 완료: Polygon → LineString 변환")
        
        elif buffered.geom_type == 'LineString':
            result = buffered
            logger.info(f"✅ Buffer 완료: LineString 유지")
        
        else:
            logger.warn(f"예상치 못한 geom_type: {buffered.geom_type}, simplified 반환")
            return simplified
        
        return result
    
    except Exception as e:
        logger.error(f"스무딩/오프셋 처리 실패: {e}")
        return line


def _path_to_geojson_coords(G, G_proj, route):
    """
    경로(노드 리스트)를 GeoJSON 좌표로 변환합니다.
    각 엣지의 실제 geometry를 추출하고, 없으면 직선으로 대체합니다.
    
    ✅ 중복 좌표 제거 로직 추가
    """
    coords = []
    
    if not route or len(route) < 2:
        raise ValueError(f"경로가 유효하지 않습니다: {route}")
    
    for i in range(len(route) - 1):
        u, v = route[i], route[i + 1]
        
        if u not in G or v not in G:
            raise ValueError(f"그래프에 없는 노드: u={u}, v={v}")
        
        edge_data = G.get_edge_data(u, v)
        if edge_data is None:
            # fallback: 직선으로 대체
            lat_u, lon_u = G.nodes[u]['y'], G.nodes[u]['x']
            lat_v, lon_v = G.nodes[v]['y'], G.nodes[v]['x']
            
            # ✅ 이전 좌표가 없거나 다르면 추가
            if not coords or coords[-1] != [lon_u, lat_u]:
                coords.append([lon_u, lat_u])
            coords.append([lon_v, lat_v])
            continue
        
        # geometry가 있으면 사용
        if 'geometry' in edge_data and edge_data['geometry'] is not None:
            geom = edge_data['geometry']
            if hasattr(geom, 'coords'):
                edge_coords = list(geom.coords)
                
                # ✅ 첫 좌표 중복 제거
                for j, coord in enumerate(edge_coords):
                    coord_pair = [coord[0], coord[1]]
                    
                    # 첫 좌표이고 이전 좌표와 같으면 스킵
                    if j == 0 and coords and coords[-1] == coord_pair:
                        continue
                    
                    coords.append(coord_pair)
            else:
                # geometry가 invalid하면 직선
                lat_u, lon_u = G.nodes[u]['y'], G.nodes[u]['x']
                lat_v, lon_v = G.nodes[v]['y'], G.nodes[v]['x']
                
                if not coords or coords[-1] != [lon_u, lat_u]:
                    coords.append([lon_u, lat_u])
                coords.append([lon_v, lat_v])
        else:
            # geometry 없으면 직선으로 대체
            lat_u, lon_u = G.nodes[u]['y'], G.nodes[u]['x']
            lat_v, lon_v = G.nodes[v]['y'], G.nodes[v]['x']
            
            if not coords or coords[-1] != [lon_u, lat_u]:
                coords.append([lon_u, lat_u])
            coords.append([lon_v, lat_v])

    return coords




def _route_stats(
    G: nx.MultiDiGraph,
    route: List[int]
) -> Dict[str, float]:
    """
    경로의 실제 거리(m)와 ai_score 합산 계산
    
    Args:
        G: 그래프
        route: 노드 ID 리스트
    
    Returns:
        {"distance_m": float, "ai_score": float}
    """
    total_dist = 0.0
    total_score = 0.0
    
    for u, v in zip(route[:-1], route[1:]):
        if not G.has_edge(u, v):
            logger.warn(f"엣지 ({u}, {v}) 없음")
            continue
        
        data = G[u][v][0]  # MultiDiGraph의 첫 번째 엣지
        total_dist += data.get('length', 0)
        total_score += data.get('ai_score', 0)
    
    return {"distance_m": total_dist, "ai_score": total_score}


def _score_to_grade(ai_score: float, distance_m: float) -> str:
    """
    단위 거리당 ai_score로 안전 등급 산정
    (낮을수록 안전 = 페널티가 적게 쌓였다는 뜻)
    
    Args:
        ai_score: 총 AI 스코어 합
        distance_m: 총 거리 (m)
    
    Returns:
        등급 ("A", "B", "C", "D")
    """
    if distance_m == 0:
        return "D"
    
    ratio = ai_score / distance_m
    
    if ratio < 2:
        return "A"
    elif ratio < 5:
        return "B"
    elif ratio < 10:
        return "C"
    else:
        return "D"


# ════════════════════════════════════════════════════════
# 🧭 Part 2: 양방향 페널티 차단 (이슈 1-2 해결)
# ════════════════════════════════════════════════════════

def _apply_bidirectional_penalty(
    G: nx.MultiDiGraph,
    used_edges: Set[Tuple[int, int]],
    penalty: float = 99999.0
) -> int:
    """
    지나온 엣지의 양방향(u→v, v→u)에 동시에 페널티를 부여합니다.
    U턴, 360도 회전, 역주행을 원천 차단합니다.
    
    [핵심 개선]
    ❌ 기존: (u, v)에만 페널티
    ✅ 개선: (u, v) + (v, u) 양쪽 모두 페널티
    
    Args:
        G: NetworkX MultiDiGraph
        used_edges: {(u1, v1), (u2, v2), ...} 사용된 엣지 집합
        penalty: 페널티 값 (기본 99999)
    
    Returns:
        페널티 적용된 총 엣지 수
    """
    penalty_count = 0
    
    for u, v in used_edges:
        # 정방향 (u → v) 페널티
        if G.has_edge(u, v):
            current_score = G[u][v][0].get('ai_score', 1.0)
            G[u][v][0]['ai_score'] = current_score + penalty
            penalty_count += 1
            logger.debug(f"페널티 적용: ({u}→{v}) +{penalty}")
        
        # 역방향 (v → u) 페널티 (이전엔 없었음!)
        if G.has_edge(v, u):
            current_score = G[v][u][0].get('ai_score', 1.0)
            G[v][u][0]['ai_score'] = current_score + penalty
            penalty_count += 1
            logger.debug(f"페널티 적용: ({v}→{u}) +{penalty} [역방향]")
    
    logger.info(f"✅ 양방향 페널티 적용 완료: {penalty_count}개 엣지")
    return penalty_count


# ════════════════════════════════════════════════════════
# 🔺 Part 3: 트라이앵글 웨이포인트 알고리즘 (이슈 2 해결)
# ════════════════════════════════════════════════════════

def _calculate_triangle_waypoints(
    center_lat: float,
    center_lng: float,
    target_dist_m: float,
    base_angle_deg: float = 0.0
) -> Tuple[Tuple[float, float], Tuple[float, float]]:
    """
    트라이앵글 웨이포인트 계산
    
    [알고리즘]
    1. 목표 거리 = 원의 둘레 → 반지름 계산: r = dist / 2π
    2. 웨이포인트 1(WP1): 기본 각도 0° 방향, 반지름 × 0.95
    3. 웨이포인트 2(WP2): 기본 각도 +120° 방향, 반지름 × 0.95
    4. 경로: [출발지] → [WP1] → [WP2] → [출발지]
    
    [결과]
    삼각형/원형 궤적으로 동네를 크게 일주하는 경로 생성
    
    Args:
        center_lat: 출발지 위도
        center_lng: 출발지 경도
        target_dist_m: 목표 거리 (m)
        base_angle_deg: 기본 각도 (회전용)
    
    Returns:
        ((wp1_lat, wp1_lng), (wp2_lat, wp2_lng))
    """
    # 1️⃣ 반지름 계산
    radius_m = target_dist_m / (2 * math.pi)
    wp_radius_m = radius_m * 0.95  # 약간 안쪽
    
    logger.info(f"🔺 트라이앵글 웨이포인트 계산")
    logger.debug(f"   목표거리: {target_dist_m}m → 반지름: {radius_m:.1f}m → WP반지름: {wp_radius_m:.1f}m")
    
    # 2️⃣ 위도/경도 스케일 (1도 ≈ 111km)
    lat_per_m = 1.0 / 111000.0
    lng_per_m = 1.0 / (111000.0 * math.cos(math.radians(center_lat)))
    
    # 3️⃣ WP1: base_angle 방향 (0도)
    angle1_rad = math.radians(base_angle_deg)
    wp1_lat = center_lat + wp_radius_m * math.sin(angle1_rad) * lat_per_m
    wp1_lng = center_lng + wp_radius_m * math.cos(angle1_rad) * lng_per_m
    
    logger.debug(f"   WP1 ({base_angle_deg:.0f}°): ({wp1_lat:.6f}, {wp1_lng:.6f})")
    
    # 4️⃣ WP2: base_angle + 120도 방향
    angle2_deg = base_angle_deg + 120.0
    angle2_rad = math.radians(angle2_deg)
    wp2_lat = center_lat + wp_radius_m * math.sin(angle2_rad) * lat_per_m
    wp2_lng = center_lng + wp_radius_m * math.cos(angle2_rad) * lng_per_m
    
    logger.debug(f"   WP2 ({angle2_deg:.0f}°): ({wp2_lat:.6f}, {wp2_lng:.6f})")
    
    return (wp1_lat, wp1_lng), (wp2_lat, wp2_lng)


def _find_best_loop_via_triangle_waypoints(
    G: nx.MultiDiGraph,
    G_proj: nx.MultiDiGraph,
    origin_node: int,
    target_dist_m: float,
    mode: str = "balanced"
) -> Optional[List[int]]:
    """
    트라이앵글 웨이포인트를 이용한 루프 경로 탐색
    
    [구조]
    [출발지] → [WP1] → [WP2] → [출발지]
    
    각 구간마다 이전 엣지에 누적 페널티를 부여하여
    경로가 절대 겹치지 않도록 강제합니다.
    
    Args:
        G: 원본 그래프
        G_proj: 투영 그래프
        origin_node: 출발 노드
        target_dist_m: 목표 거리
        mode: "balanced" / "fastest" / "safest"
    
    Returns:
        경로 리스트 또는 None (실패)
    """
    logger.info(f"🔺 트라이앵글 웨이포인트 루프 탐색 시작 (목표: {target_dist_m/1000:.1f}km)")
    
    ox_data = G.nodes[origin_node]
    orig_lat = ox_data['y']
    orig_lng = ox_data['x']
    
    logger.debug(f"   출발지 노드: {origin_node}, 좌표: ({orig_lat:.6f}, {orig_lng:.6f})")
    
    # 1️⃣ 트라이앵글 웨이포인트 생성
    wp1, wp2 = _calculate_triangle_waypoints(
        orig_lat, orig_lng, target_dist_m, base_angle_deg=0.0
    )
    
    # 2️⃣ 각 웨이포인트의 가장 가까운 노드 찾기
    try:
        wp1_node = ox.distance.nearest_nodes(G, X=wp1[1], Y=wp1[0])
        wp2_node = ox.distance.nearest_nodes(G, X=wp2[1], Y=wp2[0])
        logger.info(f"✅ WP 노드 검색: WP1={wp1_node}, WP2={wp2_node}")
    except Exception as e:
        logger.error(f"웨이포인트 노드 검색 실패: {e}")
        return None
    
    # 3️⃣ 3개 구간 정의
    segments = [
        (origin_node, wp1_node, "START→WP1"),
        (wp1_node, wp2_node, "WP1→WP2"),
        (wp2_node, origin_node, "WP2→START")
    ]
    
    # 4️⃣ 임시 그래프 복사 (페널티 적용용)
    G_tmp = G.copy()
    
    all_route_nodes = []
    accumulated_edges: Set[Tuple[int, int]] = set()
    
    # 5️⃣ 구간별 Dijkstra + 누적 페널티
    for seg_idx, (from_node, to_node, label) in enumerate(segments):
        logger.debug(f"\n   [구간 {seg_idx + 1}] {label}")
        
        # 이전 구간의 엣지에 누적 페널티 적용
        if accumulated_edges:
            # 누적 페널티: 99999 × (seg_idx + 1)
            # seg 0: 페널티 없음
            # seg 1: 99999 × 1 = 99999
            # seg 2: 99999 × 2 = 199998 (더 강한 차단)
            penalty = 99999.0 * seg_idx
            logger.debug(f"   이전 구간 엣지 {len(accumulated_edges)}개에 페널티 {penalty:.0f} 적용")
            _apply_bidirectional_penalty(G_tmp, accumulated_edges, penalty=penalty)
        
        # Dijkstra 계산
        try:
            segment_path = nx.dijkstra_path(
                G_tmp, from_node, to_node, weight='ai_score'
            )
            segment_dist = sum([G[segment_path[i]][segment_path[i+1]][0].get('length', 0) for i in range(len(segment_path)-1)])
            logger.info(f"✅ Dijkstra {label}: {len(segment_path)}개 노드, {segment_dist:.0f}m")
        
        except (nx.NetworkXNoPath, nx.NodeNotFound) as e:
            logger.error(f"❌ Dijkstra 실패 {label}: {e}")
            return None
        
        # 경로 누적 (중복 제거)
        if seg_idx == 0:
            all_route_nodes = segment_path
        else:
            all_route_nodes.extend(segment_path[1:])
        
        # 이 구간의 엣지 기록 (누적용)
        for i in range(len(segment_path) - 1):
            accumulated_edges.add((segment_path[i], segment_path[i + 1]))
    
    logger.info(f"✅ 트라이앵글 루프 완성: {len(all_route_nodes)}개 노드")
    return all_route_nodes


def _find_best_loop_via_anchor(
    G: nx.MultiDiGraph,
    G_proj: nx.MultiDiGraph,
    origin_node: int,
    target_dist_m: float,
    n_directions: int = 8,
    mode: str = "balanced",
) -> Optional[List[int]]:
    """
    기존 방사형 앵커 방식 (폴백용)
    트라이앵글 웨이포인트가 실패하면 이를 사용합니다.
    """
    logger.info(f"📡 폴백: 방사형 앵커 루프 탐색 (방향: {n_directions}개)")
    
    ox_data = G.nodes[origin_node]
    orig_lat = ox_data['y']
    orig_lng = ox_data['x']

    # 위도/경도 오프셋 계산
    offset_deg = (target_dist_m / 2) * 0.000009
    angles = np.linspace(0, 360, n_directions, endpoint=False)

    tolerance = {"fastest": 0.30, "balanced": 0.20, "safest": 0.15}[mode]

    candidates = []

    for angle in angles:
        rad = np.radians(angle)
        anchor_lat = orig_lat + offset_deg * np.cos(rad)
        anchor_lng = orig_lng + offset_deg * np.sin(rad)
        
        try:
            anchor_node = ox.distance.nearest_nodes(G, X=anchor_lng, Y=anchor_lat)
        except:
            continue

        if anchor_node == origin_node:
            continue

        try:
            # 가는 경로
            path_go = nx.dijkstra_path(G, origin_node, anchor_node, weight='ai_score')

            # 돌아오는 경로 (갔던 엣지에 양방향 페널티)
            G_tmp = G.copy()
            used_edges = {(path_go[i], path_go[i + 1]) for i in range(len(path_go) - 1)}
            _apply_bidirectional_penalty(G_tmp, used_edges)

            path_ret = nx.dijkstra_path(G_tmp, anchor_node, origin_node, weight='ai_score')

            full_path = path_go + path_ret[1:]
            stats = _route_stats(G, full_path)
            total_dist = stats["distance_m"]

            # 거리 오차 필터링
            dist_err = abs(total_dist - target_dist_m) / target_dist_m
            if dist_err > tolerance:
                continue

            # 모드별 점수 계산
            dist_penalty = dist_err * 10000
            if mode == "fastest":
                combined = dist_penalty
            elif mode == "safest":
                combined = stats["ai_score"]
            else:  # balanced
                combined = dist_penalty * 0.5 + stats["ai_score"] * 0.5

            candidates.append({
                "path": full_path,
                "score": combined,
                "distance": total_dist,
                "ai_score": stats["ai_score"],
                "angle": angle,
            })

        except (nx.NetworkXNoPath, nx.NodeNotFound):
            continue

    if not candidates:
        logger.error("❌ 방사형 앵커로도 경로를 찾을 수 없음")
        return None

    best = min(candidates, key=lambda c: c["score"])
    logger.info(f"✅ 최적 앵커 선택 (각도: {best['angle']:.0f}°, 거리: {best['distance']/1000:.2f}km)")
    return best["path"]


def _compute_bbox(coords: list) -> dict:
    """
    좌표 리스트에서 바운딩 박스를 계산합니다.
    
    Args:
        coords: [[lon, lat], [lon, lat], ...] 형식의 좌표 리스트
    
    Returns:
        {'min_lat': ..., 'max_lat': ..., 'min_lng': ..., 'max_lng': ...}
    """
    if not coords or len(coords) < 1:
        return {}
    
    lons = [c[0] for c in coords]
    lats = [c[1] for c in coords]
    
    bbox = {
        "min_lat": min(lats),
        "max_lat": max(lats),
        "min_lng": min(lons),
        "max_lng": max(lons),
    }
    
    print(f"[DEBUG] _compute_bbox: {bbox}")
    return bbox




# ════════════════════════════════════════════════════════
# 🏃 A→B 직선 코스
# ════════════════════════════════════════════════════════

def compute_ab_route(
    G: nx.MultiDiGraph,
    G_proj: nx.MultiDiGraph,
    start_lat: float,
    start_lng: float,
    end_lat: float,
    end_lng: float,
) -> Dict:
    """
    A→B 최적 경로 계산
    
    Args:
        G, G_proj: 그래프
        start_lat, start_lng: 시작점
        end_lat, end_lng: 끝점
    
    Returns:
        {
            "route": [노드 ID 리스트],
            "coords": [(lat, lng), ...],
            "distance_m": float,
            "ai_score": float,
            "safety_grade": "A" | "B" | "C" | "D"
        }
    """
    logger.info(f"🏃 A→B 경로 계산 시작")
    logger.debug(f"   출발: ({start_lat:.6f}, {start_lng:.6f})")
    logger.debug(f"   도착: ({end_lat:.6f}, {end_lng:.6f})")
    
    try:
        start_node = ox.distance.nearest_nodes(G, X=start_lng, Y=start_lat)
        end_node = ox.distance.nearest_nodes(G, X=end_lng, Y=end_lat)
        
        logger.debug(f"   노드: {start_node} → {end_node}")
    except Exception as e:
        logger.error(f"노드 검색 실패: {e}")
        raise ValueError("시작점 또는 끝점이 도로 네트워크 밖입니다")

    try:
        route = ox.shortest_path(G, start_node, end_node, weight='ai_score')
    except nx.NetworkXNoPath:
        logger.error("경로를 찾을 수 없습니다")
        raise ValueError("경로를 찾을 수 없습니다")

    if not route:
        raise ValueError("경로가 비어있습니다")

    coords = _path_to_geojson_coords(G, G_proj, route)
    stats = _route_stats(G, route)
    grade = _score_to_grade(stats["ai_score"], stats["distance_m"])

    logger.info(f"✅ A→B 경로 완성: {stats['distance_m']/1000:.2f}km, 등급: {grade}")

    bbox = _compute_bbox(result["coords"])

    return {
        "route": route,
        "coords": coords,
        "distance_m": stats["distance_m"],
        "ai_score": stats["ai_score"],
        "safety_grade": grade,
        "bbox": bbox,
    }


# ════════════════════════════════════════════════════════
# 🍩 루프 코스 (원점 회귀) - 트라이앵글 + 누적 페널티
# ════════════════════════════════════════════════════════

def compute_loop_route(
    G: nx.DiGraph, 
    G_proj: nx.DiGraph,
    start_lat: float, 
    start_lng: float,
    target_distance: float,
    n_directions: int = 3,
    mode: str = "balanced",
) -> dict:
    """
    원점 회귀 루프 코스를 계산합니다.
    
    Args:
        G: OSM 그래프 (위도/경도)
        G_proj: 프로젝션 그래프 (미터)
        start_lat, start_lng: 출발지 좌표
        target_distance: 목표 거리 (미터)
        n_directions: 웨이포인트 개수
        mode: 경로 모드 (balanced, safe, fast)
    
    Returns:
        {
            'coords': [...],           # GeoJSON 좌표
            'distance_m': float,       # 총 거리
            'ai_score': float,         # 안전 점수
            'bbox': {...}              # 바운딩 박스
        }
    """
    
    print(f"\n[INFO] ============================================================")
    print(f"[INFO] 🍩 루프 코스 계산 시작 (목표: {target_distance/1000:.1f}km, 모드: {mode})")
    print(f"[INFO] ============================================================")
    
    # 1️⃣ 출발지 노드 찾기
    start_node = ox.distance.nearest_nodes(G, start_lng, start_lat)
    print(f"[DEBUG]    출발지 노드: {start_node}")
    
    # 2️⃣ 트라이앵글 웨이포인트 계산
    print(f"\n[1차] 트라이앵글 웨이포인트 시도...")
    
    # ✅ 올바른 함수명으로 변경
    route = _find_best_loop_via_triangle_waypoints(
        G, G_proj, start_node, target_distance, mode=mode
    )
    
    # 트라이앵글 실패 → 폴백
    if not route or len(route) < 3:
        print(f"[WARNING] 트라이앵글 루프 실패, 폴백 시도...")
        route = _find_best_loop_via_anchor(
            G, G_proj, start_node, target_distance, n_directions=n_directions, mode=mode
        )
    
    if not route or len(route) < 3:
        print(f"[ERROR] 모든 루프 탐색 방식 실패")
        raise ValueError("루프 경로를 찾을 수 없습니다")
    
    print(f"[INFO]  ✅ 루프 경로 완성: {len(route)}개 노드")

    
    # 3️⃣ 좌표 변환 (여기서 route를 사용)
    print(f"\n[STEP] 좌표 변환...")
    coords = _path_to_geojson_coords(G, G_proj, route)
    
    if not coords or len(coords) < 2:
        print(f"[ERROR] 좌표 변환 실패")
        raise ValueError("경로를 좌표로 변환할 수 없습니다")
    
    print(f"[DEBUG]    변환된 좌표: {len(coords)}개")
    
    # 4️⃣ 거리 & 안전 점수 계산 (통합)
    print(f"\n[STEP] 거리 및 안전 점수 계산...")
    stats = _route_stats(G, route)
    distance_m = stats["distance_m"]
    ai_score = stats["ai_score"]
    print(f"[DEBUG]    총 거리: {distance_m:.1f}m")
    print(f"[DEBUG]    안전 점수: {ai_score:.1f}")
    
    # 5️⃣ 결과 딕셔너리 생성 (이 시점에서 모든 데이터가 준비됨)
    print(f"\n[STEP] 결과 딕셔너리 생성...")
    result = {
        "coords": coords,
        "distance_m": distance_m,
        "ai_score": ai_score,
        "route": route,  # 원본 노드 경로도 포함
    }
    print(f"[DEBUG]    result 키: {list(result.keys())}")
    
    # 6️⃣ 바운딩 박스 계산 (coords 완성 후)
    print(f"\n[STEP] 바운딩 박스 계산...")
    try:
        bbox = _compute_bbox(result["coords"])
        result["bbox"] = bbox
        print(f"[DEBUG]    bbox: {bbox}")
    except Exception as e:
        print(f"[WARNING] bbox 계산 실패: {e}")
        result["bbox"] = {}
    
    print(f"\n[INFO] ✅ 루프 코스 계산 완료\n")
    return result