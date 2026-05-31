import osmnx as ox
import geopandas as gpd

print("🌳 1. 광주 북구의 안전 구역(공원, 대학교, 트랙)을 탐색합니다...")
place_name = "Buk-gu, Gwangju, South Korea"

# 우리가 찾고 싶은 화이트리스트 태그들
tags = {
    'leisure': ['park', 'track', 'pitch'],
    'amenity': ['university', 'college']
}

try:
    # OSM 서버에서 해당 태그를 가진 모든 지형 데이터를 가져옴
    safe_zones = ox.features_from_place(place_name, tags)

    # 점(Point) 데이터는 제외하고, 넓이가 있는 면적(Polygon, MultiPolygon)만 필터링
    safe_polygons = safe_zones[safe_zones.geometry.type.isin(['Polygon', 'MultiPolygon'])].copy()

    print(f"✅ 탐색 완료! 북구에서 총 {len(safe_polygons)}개의 안전 구역(폴리곤)을 찾았습니다!\n")
    
    # 찾은 데이터 중 이름이 있는 것만 몇 개 미리보기
    print("=== 📍 찾은 안전 구역 리스트 (일부) ===")
    if 'name' in safe_polygons.columns:
        print(safe_polygons['name'].dropna().head(10).to_list())
    
    # 나중에 AI 엔진에서 쓰기 쉽도록 GeoJSON 파일로 저장
    output_file = "bukgu_safe_zones.geojson"
    
    # [수정됨] geometry(지도 형태) 컬럼을 제외한 나머지 컬럼만 안전하게 문자열로 변환
    for col in safe_polygons.columns:
        if col != 'geometry':
            safe_polygons[col] = safe_polygons[col].apply(lambda x: str(x) if isinstance(x, list) else x)
            
    safe_polygons.to_file(output_file, driver="GeoJSON")
    
    print(f"\n🎉 성공적으로 '{output_file}' 파일로 저장했습니다!")
    
except Exception as e:
    print(f"❌ 에러가 발생했습니다: {e}")