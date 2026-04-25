import 'package:flutter/material.dart';
import 'result_screen.dart';

// ═══════════════════════════════════════════════════════════
// 🗺️ COURSE RUNNING SCREEN
// 코스 러닝 모드 전용 화면 (기존 RunningScreen 복사본)
// 차이점: AI 경로선 표시 + 남은 코스 거리 + 프로그레스 바
// ═══════════════════════════════════════════════════════════
class CourseRunningScreen extends StatelessWidget {
  final double targetDistance;
  final String courseType;
  final bool safeMode;

  const CourseRunningScreen({
    super.key,
    required this.targetDistance,
    required this.courseType,
    required this.safeMode,
  });

  static const Color kPurple = Color(0xFF7C6BFF);

  @override
  Widget build(BuildContext context) {
    // ═══════════════════════════════════════════
    // 🎯 가짜 데이터 (추후 실제 러닝 로직과 연동)
    // ═══════════════════════════════════════════
    const double currentDistance = 3.0; // 현재 달린 거리 (km)
    final double progressRate =
        currentDistance / targetDistance; // 진행률 (0.0~1.0)
    final double remainingDistance = targetDistance - currentDistance; // 남은 거리

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ═════════════════════════════════════
            // 지도 영역 (AI 경로선 표시)
            // ═════════════════════════════════════
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🗺️ MAP AREA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // ⬇️ AI 코스 경로선 표시 영역
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: kPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🤖 AI 코스 경로선 표시 영역',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
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
                          '달리는 아바타',
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
            ),

            // ═════════════════════════════════════
            // 🎯 목표 거리 대비 진행률 프로그레스 바
            // ═════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 달성률 텍스트 (오른쪽 정렬)
                  Text(
                    '목표까지 ${(progressRate * 100).toStringAsFixed(0)}% 달성! · 남은 거리: ${remainingDistance.toStringAsFixed(1)}km',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 프로그레스 바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12), // 둥근 모서리
                    child: LinearProgressIndicator(
                      value: progressRate, // 진행률 (0.0 ~ 1.0)
                      minHeight: 16, // 막대 두께
                      backgroundColor: const Color(0xFFEDE9FF), // 연한 보라색 배경
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        kPurple, // 채워지는 색 (진한 퍼플)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═════════════════════════════════════
            // 러닝 정보창 (거리/페이스/시간 + 남은 코스 거리)
            // ═════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // 기존 3개 (거리/페이스/시간)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _InfoItem(value: '3.14', unit: 'km', label: '거리'),
                      _InfoItem(value: "5'30\"", unit: '/km', label: '페이스'),
                      _InfoItem(value: '17:30', unit: 'time', label: '시간'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ⬇️ 남은 코스 거리
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kPurple.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '남은 코스 거리',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D3A),
                          ),
                        ),
                        Text(
                          '${remainingDistance.toStringAsFixed(2)} km',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ═════════════════════════════════════
            // 조작 버튼부 (일시정지 / 종료)
            // ═════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.pause, size: 24),
                      label: const Text(
                        '일시정지',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ✅ 결과 화면으로 이동 (뒤로가기 불가능하게 교체)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResultScreen(),
                          ),
                        );
                      },

                      icon: const Icon(Icons.stop, size: 24),
                      label: const Text(
                        '종료',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E5E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📊 _InfoItem: 러닝 정보 한 칸 위젯 (거리/페이스/시간 공통)
// 숫자는 크고 굵게, 단위와 라벨은 작게
// ═══════════════════════════════════════════════════════════
class _InfoItem extends StatelessWidget {
  final String value; // 큰 숫자 (예: '3.14')
  final String unit; // 단위 (예: 'km')
  final String label; // 라벨 (예: '거리')

  const _InfoItem({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔢 큰 숫자
        Text(
          value,
          style: const TextStyle(
            fontSize: 24, // 요청대로 24
            fontWeight: FontWeight.bold, // 두껍게
            color: Color(0xFF2D2D3A),
          ),
        ),
        const SizedBox(height: 4),
        // 📐 단위 (작게)
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        // 🏷️ 라벨 (제일 작게)
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
