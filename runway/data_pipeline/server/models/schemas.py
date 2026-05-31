# server/models/schemas.py
from pydantic import BaseModel, Field, field_validator
from typing import Literal

# ── 요청 모델 ──────────────────────────────────────────
class RouteRequest(BaseModel):
    """A→B 직선 코스 요청"""
    start_lat: float = Field(..., ge=-90,  le=90,  example=35.1775)
    start_lng: float = Field(..., ge=-180, le=180, example=126.9048)
    end_lat:   float = Field(..., ge=-90,  le=90,  example=35.1655)
    end_lng:   float = Field(..., ge=-180, le=180, example=126.9092)

class LoopRouteRequest(BaseModel):
    """원점 회귀 루프 코스 요청"""
    start_lat:       float = Field(..., ge=-90,  le=90,  example=35.1775)
    start_lng:       float = Field(..., ge=-180, le=180, example=126.9048)
    target_distance: float = Field(..., ge=1000, le=42195, example=5000,
                                   description="목표 거리 (미터 단위, 1km~42.195km)")
    n_directions:    int   = Field(default=8, ge=4, le=16,
                                   description="방사형 탐색 방향 수 (많을수록 정밀, 느림)")
    mode: Literal["fastest", "balanced", "safest"] = Field(
        default="balanced",
        description="fastest=거리 우선 / balanced=균형 / safest=안전 최우선"
    )

    @field_validator("target_distance")
    @classmethod
    def round_to_hundred(cls, v: float) -> float:
        """100m 단위 반올림 — 너무 정밀한 요청 방지"""
        return round(v / 100) * 100


# ── 응답 모델 ──────────────────────────────────────────
class RouteFeature(BaseModel):
    """GeoJSON Feature 하나 (경로 선 또는 마커)"""
    type:       str  = "Feature"
    geometry:   dict         # GeoJSON geometry object
    properties: dict         # 메타데이터

class RouteResponse(BaseModel):
    """경로 탐색 응답"""
    status:           Literal["ok", "error"]
    route_type:       Literal["a_to_b", "loop"]
    total_distance_m: float  = Field(..., description="실제 이동 거리 (미터)")
    ai_score_total:   float  = Field(..., description="AI 안전 점수 합산 (낮을수록 안전)")
    safety_grade:     Literal["A", "B", "C", "D"] = Field(
                          ..., description="안전 등급 (A=최우수)")
    geojson: dict            # GeoJSON FeatureCollection (경로 + 마커)
    message: str = ""
