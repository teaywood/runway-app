import 'package:flutter/material.dart';
import '../main.dart'; // HomeScreen을 불러오기 위함

// ═══════════════════════════════════════════════════════════
// 🏆 RESULT SCREEN
// 러닝 종료 후 결과를 보여주는 화면
// 디자인: 화이트 배경 + 라벤더/퍼플 포인트 컬러
// ═══════════════════════════════════════════════════════════
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const Color kPurple = Color(0xFF7C6BFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ═══════════════════════════════════════════
      // AppBar
      // ═══════════════════════════════════════════
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
        title: const Text(
          'RUN-WAY',
          style: TextStyle(
            color: kPurple,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: kPurple),
            onPressed: () {
              // TODO: 설정 메뉴
            },
          ),
        ],
      ),
      // ═══════════════════════════════════════════
      // Body (스크롤 가능)
      // ═══════════════════════════════════════════
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────
              // 1️⃣ 달린 코스 영역
              // ─────────────────────────────────────
              const Text(
                '달린 코스',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D3A),
                ),
              ),
              const SizedBox(height: 12),
              // 가짜 지도 영역
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    // 지도 배경
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '🗺️ 달린 경로 지도',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    // 좌측 하단: 박수 치는 아바타
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          '박수 치는 아바타',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D3A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ─────────────────────────────────────
              // 2️⃣ 러닝 기록 영역
              // ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '러닝 기록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D3A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: kPurple),
                    onPressed: () {
                      // TODO: 공유 기능
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 경험치 바 (얇은 프로그레스)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.65, // 예시: 65% 달성
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEDE9FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(kPurple),
                ),
              ),
              const SizedBox(height: 24),

              // 기록 데이터 + 상세 기록 버튼
              Stack(
                children: [
                  // 좌측: 기록 데이터
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. 좌측: 러닝 기록 리스트 (거리, 시간, 페이스, 칼로리)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RecordItem(label: '거리', value: '6.12', unit: 'km'),
                            const SizedBox(height: 24),
                            _RecordItem(label: '시간', value: '39:47', unit: ''),
                            const SizedBox(height: 24),
                            _RecordItem(
                              label: '페이스',
                              value: "6'30\"",
                              unit: '/km',
                            ),
                            const SizedBox(height: 24),
                            _RecordItem(
                              label: '칼로리 소모량',
                              value: '367',
                              unit: 'kcal',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─────────────────────────────────────
              // 3️⃣ 하단 조작부 (보상확인 / 홈)
              // ─────────────────────────────────────
              Row(
                children: [
                  // 보상확인 버튼 (아웃라인)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: 보상 확인 화면
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPurple, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '보상확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 홈 버튼 (퍼플 배경)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ 하단 탭 바를 포함한 메인 화면으로 돌아가면서 이전 화면 스택 모두 제거
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                          (route) => false, // 모든 이전 화면 제거
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '홈',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📊 _RecordItem: 기록 항목 위젯 (거리/시간/페이스/칼로리)
// ═══════════════════════════════════════════════════════════
class _RecordItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _RecordItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D3A),
            ),
            children: [
              TextSpan(text: value),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
