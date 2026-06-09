# runway-app

## 플러터 실행
cd runway
flutter run -d web-server --web-port=8080


## 경로 탐색 알고리즘 테스트
cd /workspaces/runway-app/runway/data_pipeline
source .venv/bin/activate

uvicorn server.main:app --reload --host 0.0.0.0 --port 8000