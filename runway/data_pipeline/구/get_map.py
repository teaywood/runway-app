import osmnx as ox

# 1. 타겟 지역 설정
place_name = "Buk-gu, Gwangju, South Korea"

print(f"🚀 [{place_name}] 지역의 도로망 데이터를 요청합니다...")
print("OSM 서버에서 데이터를 다운받고 있습니다. (1~2분 정도 소요)\n")

try:
    # 2. 러너가 뛸 수 있는 보행자 도로(walk)만 쏙 뽑아오기
    # 차만 다니는 고속도로는 제외되고, 골목길, 공원 길, 인도가 포함됩니다.
    G = ox.graph_from_place(place_name, network_type='walk')

    # 3. 데이터가 얼마나 모였는지 확인
    print("✅ 도로망 데이터 추출 완료!\n")
    
    # 노드(교차로)와 엣지(길)의 개수 확인
    num_nodes = len(G.nodes)
    num_edges = len(G.edges)
    print(f"📍 교차로(점) 개수: {num_nodes:,}개")
    print(f"🛣️ 연결된 길(선) 개수: {num_edges:,}개\n")

    # 4. 알고리즘과 DB에 넣기 쉬운 GraphML 파일로 저장
    output_file = "bukgu_run_network.graphml"
    ox.save_graphml(G, filepath=output_file)
    print(f"🎉 성공적으로 '{output_file}' 파일로 저장했습니다!")
    
except Exception as e:
    print(f"❌ 에러가 발생했습니다: {e}")