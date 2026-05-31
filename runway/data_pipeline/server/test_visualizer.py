import requests
import folium
from folium import plugins
import json

# FastAPI 서버 주소
API_URL = "http://localhost:8000/api/v1/loop-route"

# 1. API에 보낼 요청 데이터
payload = {
    "start_lat": 35.1775,
    "start_lng": 126.9048,
    "target_distance": 5000,  # 5km 루프
    "mode": "balanced"
}

print("📡 FastAPI 서버에 경로 계산을 요청합니다...")
response = requests.post(API_URL, json=payload)

if response.status_code == 200:
    data = response.json()
    print(f"✅ 경로 수신 완료! (총 거리: {data['total_distance_m']}m, 등급: {data['safety_grade']})")
    
    geojson_data = data['geojson']
    
    # 디버그: GeoJSON 구조 출력
    print("\n[DEBUG] GeoJSON 구조:")
    for i, feat in enumerate(geojson_data.get('features', [])[:5]):
        print(f"  Feature {i}: type={feat['geometry']['type']}, props={list(feat['properties'].keys())}")
    
    # 2. 지도 도화지 생성
    m = folium.Map(
        location=[payload['start_lat'], payload['start_lng']],
        zoom_start=14,
        tiles="cartodbpositron"
    )
    
    # 3️⃣ Feature별로 분류해서 수동으로 렌더링
    routes = []
    start_points = []
    end_points = []
    cctv_points = []
    light_points = []
    crosswalk_points = []
    
    for feature in geojson_data.get('features', []):
        geom_type = feature['geometry']['type']
        props = feature['properties']
        feat_type = props.get('type', '')
        poi_type = props.get('poi_type', '')
        
        # 경로 (LineString)
        if geom_type == 'LineString':
            routes.append(feature)
        
        # 시작점
        elif feat_type == 'start_point':
            start_points.append(feature)
        
        # 도착점
        elif feat_type == 'end_point':
            end_points.append(feature)
        
        # CCTV
        elif poi_type == 'cctv':
            cctv_points.append(feature)
        
        # 조명
        elif poi_type == 'light':
            light_points.append(feature)
        
        # 횡단보도
        elif poi_type == 'crosswalk':
            crosswalk_points.append(feature)
    
    # 4️⃣ 경로 (LineString) 렌더링 - GeoJson으로 스타일 적용
    if routes:
        route_geojson = {
            "type": "FeatureCollection",
            "features": routes
        }
        folium.GeoJson(
            route_geojson,
            style={
                'color': '#FF1493',  # 핫핑크
                'weight': 3,
                'opacity': 0.8,
            },
            name="🛣️ Route",
            show=True,
        ).add_to(m)
    
    # 5️⃣ 시작점 - 파란 원
    for feature in start_points:
        coords = feature['geometry']['coordinates']
        props = feature['properties']
        folium.CircleMarker(
            location=[coords[1], coords[0]],  # [lat, lng]
            radius=10,
            popup=f"<b>{props.get('label', 'START')}</b>",
            tooltip=props.get('label', 'START'),
            color='blue',
            fill=True,
            fillColor='blue',
            fillOpacity=0.8,
            weight=2,
        ).add_to(m)
    
    # 6️⃣ 도착점 - 빨간 원
    for feature in end_points:
        coords = feature['geometry']['coordinates']
        props = feature['properties']
        folium.CircleMarker(
            location=[coords[1], coords[0]],  # [lat, lng]
            radius=10,
            popup=f"<b>{props.get('label', 'END')}</b>",
            tooltip=props.get('label', 'END'),
            color='red',
            fill=True,
            fillColor='red',
            fillOpacity=0.8,
            weight=2,
        ).add_to(m)
    
    # 7️⃣ CCTV - 작은 빨간 원
    for feature in cctv_points:
        coords = feature['geometry']['coordinates']
        props = feature['properties']
        folium.CircleMarker(
            location=[coords[1], coords[0]],  # [lat, lng]
            radius=6,
            popup="📹 CCTV",
            tooltip="CCTV",
            color='darkred',
            fill=True,
            fillColor='red',
            fillOpacity=0.6,
            weight=1,
        ).add_to(m)
    
    # 8️⃣ 조명 - 작은 노란 원
    for feature in light_points:
        coords = feature['geometry']['coordinates']
        props = feature['properties']
        folium.CircleMarker(
            location=[coords[1], coords[0]],  # [lat, lng]
            radius=6,
            popup="💡 Street Light",
            tooltip="Light",
            color='goldenrod',
            fill=True,
            fillColor='yellow',
            fillOpacity=0.6,
            weight=1,
        ).add_to(m)
    
    # 9️⃣ 횡단보도 - 작은 초록 원
    for feature in crosswalk_points:
        coords = feature['geometry']['coordinates']
        props = feature['properties']
        folium.CircleMarker(
            location=[coords[1], coords[0]],  # [lat, lng]
            radius=6,
            popup="🚦 Crosswalk",
            tooltip="Crosswalk",
            color='darkgreen',
            fill=True,
            fillColor='lightgreen',
            fillOpacity=0.6,
            weight=1,
        ).add_to(m)
    
    # 10. 범례 추가
    legend_html = '''
    <div style="position: fixed; 
                bottom: 50px; right: 50px; width: 200px; height: auto;
                background-color: white; border:2px solid grey; z-index:9999; 
                font-size:14px; padding: 10px; border-radius: 5px;">
    <p style="margin: 0 0 10px 0;"><b>런웨이 안전 경로</b></p>
    <p><i class="fa fa-minus" style="color:#FF1493"></i> 추천 경로</p>
    <p><i class="fa fa-circle" style="color:blue"></i> 출발점</p>
    <p><i class="fa fa-circle" style="color:red"></i> 도착점</p>
    <p><i class="fa fa-circle" style="color:red"></i> CCTV</p>
    <p><i class="fa fa-circle" style="color:yellow"></i> 조명</p>
    <p><i class="fa fa-circle" style="color:lightgreen"></i> 횡단보도</p>
    </div>
    '''
    m.get_root().html.add_child(folium.Element(legend_html))
    
    # 11. 결과 저장
    output_html = "api_test_map.html"
    m.save(output_html)
    print(f"✅ 지도 생성 완료! '{output_html}'을 열어서 확인해보세요.")
    print(f"\n[정보]")
    print(f"  - 경로: {len(routes)}개 LineString")
    print(f"  - 시작점: {len(start_points)}개")
    print(f"  - 도착점: {len(end_points)}개")
    print(f"  - CCTV: {len(cctv_points)}개")
    print(f"  - 조명: {len(light_points)}개")
    print(f"  - 횡단보도: {len(crosswalk_points)}개")
    
else:
    print(f"❌ API 요청 실패: {response.status_code}")
    print(f"   응답: {response.text}")
