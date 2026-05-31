# server/api/routes.py
from fastapi import APIRouter, HTTPException
from shapely.geometry import mapping, LineString

from models.schemas import RouteRequest, LoopRouteRequest, RouteResponse
from core.graph_loader import get_graph
from core.route_engine import (
    compute_ab_route,
    compute_loop_route,
    _score_to_grade,
)

router = APIRouter(tags=["route"])


# api/routes.py의 _build_geojson() 함수 전체 대체

def _build_geojson(coords: list, route_type: str, meta: dict, pois: dict = None) -> dict:
    """
    경로 + POI를 포함한 완전한 GeoJSON FeatureCollection 생성
    
    Args:
        coords: [[lng, lat], [lng, lat], ...] ✅ 이미 GeoJSON 형식
        route_type: "a_to_b" or "loop"
        meta: {"distance_m": float, "ai_score": float, "grade": str}
        pois: {"cctv": [...], "light": [...], "crosswalk": [...]}
    
    Returns:
        GeoJSON FeatureCollection
    """
    features = []
    
    # 1️⃣ 경로 선 피처 (LineString)
    line_feature = {
        "type": "Feature",
        "geometry": {
            "type": "LineString",
            "coordinates": coords,  # ✅ 이미 [lng, lat] 순서이므로 그대로 사용
        },
        "properties": {
            "type": "route",  # ← 식별 프로퍼티
            "route_type": route_type,
            "total_distance_m": meta.get("distance_m", 0),
            "ai_score": meta.get("ai_score", 0),
            "safety_grade": meta.get("grade", "N/A"),
        },
    }
    features.append(line_feature)
    
    # 2️⃣ 시작점 마커
    if coords:
        start_feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": coords[0]  # ✅ [lng, lat]
            },
            "properties": {
                "type": "start_point",
                "marker": "start",
                "label": "출발점",
            },
        }
        features.append(start_feature)
    
    # 3️⃣ 종료점 마커
    if coords and len(coords) > 1:
        end_feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": coords[-1]  # ✅ [lng, lat]
            },
            "properties": {
                "type": "end_point",
                "marker": "end",
                "label": "도착점",
            },
        }
        features.append(end_feature)
    
    # 4️⃣ POI 피처 추가 (CCTV, 조명, 횡단보도)
    if pois:
        # CCTV
        for poi in pois.get("cctv", []):
            features.append({
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [poi["lng"], poi["lat"]]  # ✅ [lng, lat]
                },
                "properties": {
                    "type": "poi",
                    "poi_type": "cctv",
                    "icon": "📹",
                },
            })
        
        # 조명
        for poi in pois.get("light", []):
            features.append({
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [poi["lng"], poi["lat"]]  # ✅ [lng, lat]
                },
                "properties": {
                    "type": "poi",
                    "poi_type": "light",
                    "icon": "💡",
                },
            })
        
        # 횡단보도
        for poi in pois.get("crosswalk", []):
            features.append({
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [poi["lng"], poi["lat"]]  # ✅ [lng, lat]
                },
                "properties": {
                    "type": "poi",
                    "poi_type": "crosswalk",
                    "icon": "🚦",
                },
            })
    
    return {
        "type": "FeatureCollection",
        "features": features,
    }



@router.post("/route", response_model=RouteResponse, summary="A→B 안전 경로 탐색")
async def get_route(req: RouteRequest):
    """
    출발지와 목적지를 받아 AI 안전 최적 경로 + 주변 안전 인프라를 반환합니다.
    """
    try:
        from core.graph_loader import get_pois_in_bbox
        
        G, G_proj = get_graph()
        result = compute_ab_route(G, G_proj, req.start_lat, req.start_lng,
                                              req.end_lat,   req.end_lng)
        grade = _score_to_grade(result["ai_score"], result["distance_m"])
        
        # ✅ POI 추출
        bbox = result.get("bbox", {})
        pois = get_pois_in_bbox(bbox) if bbox else None
        
        # ✅ POI 포함 GeoJSON 생성
        geojson = _build_geojson(result["coords"], "a_to_b",
                                 {**result, "grade": grade}, pois=pois)

        return RouteResponse(
            status="ok",
            route_type="a_to_b",
            total_distance_m=round(result["distance_m"], 1),
            ai_score_total=round(result["ai_score"], 1),
            safety_grade=grade,
            geojson=geojson,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")



import traceback
from fastapi import HTTPException, APIRouter

@router.post("/loop-route", response_model=RouteResponse, summary="원점 회귀 루프 코스 생성")
async def get_loop_route(req: LoopRouteRequest):
    """원점 회귀 루프 코스 생성"""
    try:
        print(f"\n[STEP 1] 경로 계산 시작...")
        G, G_proj = get_graph()
        
        print(f"[STEP 2] compute_loop_route() 호출...")
        result = compute_loop_route(
            G, G_proj,
            req.start_lat, req.start_lng,
            req.target_distance,
            req.n_directions,
            req.mode,
        )
        print(f"[STEP 3] 경로 계산 완료. 반환된 키: {list(result.keys())}")
        
        print(f"[STEP 4] 등급 계산...")
        grade = _score_to_grade(result["ai_score"], result["distance_m"])
        print(f"[STEP 5] 등급 완료: {grade}")
        
        # ✅ 추가: POI 조회
        print(f"[STEP 5-1] POI 조회 시작...")
        from core.graph_loader import get_pois_in_bbox
        bbox = result.get("bbox", {})
        pois = None
        if bbox and all(k in bbox for k in ["min_lat", "max_lat", "min_lng", "max_lng"]):
            try:
                pois = get_pois_in_bbox(bbox)
                print(f"[STEP 5-2] POI 조회 완료: {len(pois.get('cctv', []))} CCTV, "
                      f"{len(pois.get('light', []))} 조명, "
                      f"{len(pois.get('crosswalk', []))} 횡단보도")
            except Exception as e:
                print(f"[WARN] POI 조회 실패: {e}")
                pois = None
        
        print(f"[STEP 6] GeoJSON 생성 시작...")
        geojson = _build_geojson(
            result["coords"], 
            "loop",
            {**result, "grade": grade}, 
            pois=pois
        )
        print(f"[STEP 7] GeoJSON 생성 완료")

        response = RouteResponse(
            status="ok",
            route_type="loop",
            total_distance_m=round(result["distance_m"], 1),
            ai_score_total=round(result["ai_score"], 1),
            safety_grade=grade,
            geojson=geojson,
        )
        print(f"[STEP 8] 응답 생성 완료")
        return response
        
    except ValueError as e:
        print(f"[ERROR] ValueError 발생: {e}")
        import traceback
        print(traceback.format_exc())
        raise HTTPException(status_code=404, detail=str(e))
        
    except Exception as e:
        print(f"[ERROR] 예상 외 예외 발생: {type(e).__name__}: {e}")
        import traceback
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"서버 오류: {type(e).__name__}: {e}")





@router.get("/health", summary="서버 헬스 체크")
async def health():
    """서버 상태 및 그래프 캐시 상태 확인"""
    from ..core.graph_loader import _G_WEIGHTED, _CACHE_HASH
    return {
        "status":       "ok",
        "graph_loaded": _G_WEIGHTED is not None,
        "cache_hash":   _CACHE_HASH[:8] + "..." if _CACHE_HASH else "not_loaded",
    }
