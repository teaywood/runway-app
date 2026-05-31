"""
🏃 Runway FastAPI 서버 진입점

[개선사항]
✅ 절대 임포트로 통일 (상대 임포트 제거)
✅ sys.path 설정으로 패키지 인식 강화
✅ 기존 lifespan 및 그래프 로더 유지
"""

import logging
import asyncio
import sys

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path

# ════════════════════════════════════════════════════════
# 📦 모듈 경로 설정 (절대 임포트 지원)
# ════════════════════════════════════════════════════════

# 현재 디렉토리 (server/)를 sys.path에 추가
server_dir = Path(__file__).parent
if str(server_dir) not in sys.path:
    sys.path.insert(0, str(server_dir))

# 부모 디렉토리 (data_pipeline/)를 sys.path에 추가
parent_dir = server_dir.parent
if str(parent_dir) not in sys.path:
    sys.path.insert(0, str(parent_dir))


# ════════════════════════════════════════════════════════
# 📥 절대 임포트로 변경
# ════════════════════════════════════════════════════════

from core.graph_loader import get_graph
from api.routes import router


# ════════════════════════════════════════════════════════
# 📊 로깅 설정
# ════════════════════════════════════════════════════════

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s"
)
logger = logging.getLogger("main")


# ════════════════════════════════════════════════════════
# 🔄 Lifespan 이벤트: 서버 시작/종료
# ════════════════════════════════════════════════════════

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    서버 시작 시 그래프 전처리를 백그라운드에서 미리 실행.
    → 첫 API 요청 시 지연 없이 즉시 응답 가능.
    
    [동작 흐름]
    1. 서버 시작 시: get_graph() 호출 → GraphML 파일 로드 및 캐싱
    2. yield: 서버 실행 (요청 처리)
    3. 서버 종료 시: 정리 로직 (필요 시)
    """
    logger.info("🚀 Runway AI 안전 러닝 코스 추천 서버 시작 중...")
    
    try:
        # 블로킹 I/O를 스레드풀에서 실행 (이벤트 루프 블로킹 방지)
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, get_graph)
        logger.info("✅ 그래프 준비 완료. 요청 수신 대기 중.")
    
    except Exception as e:
        logger.error(f"❌ 그래프 로드 실패: {e}")
        logger.warning("⚠️  GraphML 파일이 없거나 손상되었을 수 있습니다.")
    
    yield  # ← 여기서 서버 실행
    
    logger.info("👋 서버 종료.")


# ════════════════════════════════════════════════════════
# 🚀 FastAPI 앱 설정
# ════════════════════════════════════════════════════════

app = FastAPI(
    title="Runway AI Route API",
    description="야간 러너를 위한 AI 안전 코스 추천 API",
    version="2.0.0",
    lifespan=lifespan,
)

# ════════════════════════════════════════════════════════
# 🔐 CORS 설정
# ════════════════════════════════════════════════════════

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # ⚠️  프로덕션에서는 Flutter 앱 도메인으로 제한할 것
    allow_methods=["*"],
    allow_headers=["*"],
)

# ════════════════════════════════════════════════════════
# 📡 라우터 등록
# ════════════════════════════════════════════════════════

app.include_router(router, prefix="/api/v1", tags=["routes"])


# ════════════════════════════════════════════════════════
# 🏥 헬스 체크 엔드포인트
# ════════════════════════════════════════════════════════

@app.get("/")
async def root():
    """
    서버 상태 확인용 엔드포인트
    
    Returns:
        {
            "service": "Runway AI Route API",
            "status": "operational",
            "version": "2.0.0"
        }
    """
    return {
        "service": "Runway AI Route API",
        "status": "operational",
        "version": "2.0.0"
    }


@app.get("/health")
async def health_check():
    """
    Kubernetes/Docker 헬스 체크용
    """
    return {"status": "healthy"}


# ════════════════════════════════════════════════════════
# 🎯 메인 실행
# ════════════════════════════════════════════════════════

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
