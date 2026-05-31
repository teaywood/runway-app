import osmnx as ox
import folium

print("🗺️ 1. 저장된 북구 도로망을 불러오는 중...")
G = ox.load_graphml("bukgu_run_network.graphml")

# 2. 가상의 출발지(전남대)와 도착지(광주역) 위도/경도 설정
start_latlng = (35.1769, 126.9058) # 출발: 전남대학교 스포츠센터 근처
end_latlng = (35.1655, 126.9092)   # 도착: 광주역 근처

print("📍 2. 출발지와 도착지에서 가장 가까운 실제 '길(노드)'을 찾는 중...")
start_node = ox.distance.nearest_nodes(G, X=start_latlng[1], Y=start_latlng[0])
end_node = ox.distance.nearest_nodes(G, X=end_latlng[1], Y=end_latlng[0])

print("🧠 3. AI 길찾기 알고리즘 가동 (횡단보도 회피 모드!)")

# 3-1. 모든 길(Edge)을 하나씩 확인하면서 페널티 점수 매기기
for u, v, key, data in G.edges(keys=True, data=True):
    # 기본 점수는 실제 물리적 거리(m)
    running_score = data['length']
    
    # 이 길이 횡단보도(crossing)인지 이름표 확인
    is_crossing = False
    if 'crossing' in str(data.get('highway', '')) or 'crossing' in str(data.get('footway', '')):
        is_crossing = True
        
    # 횡단보도라면? 무려 500m 길이의 지옥의 길이라고 AI를 속임 (페널티 부여)
    if is_crossing:
        running_score += 500 
        
    # 계산된 러닝 전용 점수를 데이터에 저장
    data['runner_weight'] = running_score

# 3-2. 길찾기! (이제 단순히 'length'가 아니라, 우리가 만든 'runner_weight'를 기준으로 찾음)
route = ox.shortest_path(G, start_node, end_node, weight='runner_weight')

if route is None:
    print("❌ 길을 찾을 수 없습니다. (길이 끊겨있음)")
else:
    print("✅ 길찾기 성공! 지도를 그립니다...")
    
    # ---------------------------------------------------------
    # [수정된 부분] OSMnx에 의존하지 않고 Folium으로 직접 선 긋기
    # ---------------------------------------------------------
    # 4-1. 찾은 경로(route)의 노드 번호들을 실제 위도(y), 경도(x)로 변환
    route_coords = [(G.nodes[node]['y'], G.nodes[node]['x']) for node in route]
    
    # 4-2. 지도의 중심을 출발지로 잡고 기본 도화지 생성
    m = folium.Map(location=route_coords[0], zoom_start=14, tiles="cartodbpositron")
    
    # 4-3. 좌표들을 이어주는 두꺼운 민트색 선(PolyLine) 그리기
    folium.PolyLine(route_coords, color='#00FFB2', weight=6, opacity=0.8).add_to(m)
    
    # 4-4. 보너스: 출발지와 도착지에 예쁜 마커 꽂기
    folium.Marker(route_coords[0], popup="Start (전남대)", icon=folium.Icon(color="green")).add_to(m)
    folium.Marker(route_coords[-1], popup="End (광주역)", icon=folium.Icon(color="red")).add_to(m)
    
    # 4-5. 결과물 저장
    output_html = "my_first_route.html"
    m.save(output_html)
    print(f"🎉 짜잔! '{output_html}' 파일이 생성되었습니다!")