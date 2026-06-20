// lib/screen/run_screen/result/result_screen.dart
import 'package:flutter/material.dart';
import '../../../shared/widgets/main_screen.dart';

// ═══════════════════════════════════════════════════════════
// 🏆 RESULT SCREEN
// 러닝 종료 후 결과를 보여주는 화면
// 디자인: 화이트 배경 + 라벤더/퍼플 포인트 컬러
// ═══════════════════════════════════════════════════════════
class ResultScreen extends StatelessWidget {
  final String time;
  final String distance;
  final String pace;
  final String calories;
  final String? courseImagePath;
  final double progress; // ← 러닝 화면에서 넘어온 진행률 (0.0 ~ 1.0)

  const ResultScreen({
    super.key,
    required this.time,
    required this.distance,
    required this.pace,
    required this.calories,
    this.courseImagePath,
    this.progress = 0.0, // 자유 러닝 등 미전달 시 기본값
  });

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
        automaticallyImplyLeading: false,
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
              // 지도 영역 (코스 이미지 or 플레이스홀더)
              SizedBox(
                height: 250,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: courseImagePath != null
                        ? Image.asset(
                            courseImagePath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Center(
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
                          )
                        : Center(
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

              // ── 코스 달성률 프로그래스 바 (러닝 화면 연동) ──
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFEDE9FF),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(kPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 기록 데이터 + 상세 기록 버튼
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RecordItem(
                            label: '거리', value: distance, unit: 'km'),
                        const SizedBox(height: 24),
                        _RecordItem(
                            label: '시간', value: time, unit: ''),
                        const SizedBox(height: 24),
                        _RecordItem(
                            label: '페이스', value: pace, unit: '/km'),
                        const SizedBox(height: 24),
                        _RecordItem(
                            label: '칼로리 소모량',
                            value: calories,
                            unit: 'kcal'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      // TODO: 상세 기록 화면으로 이동
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '상세 기록',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kPurple,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: kPurple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─────────────────────────────────────
              // 3️⃣ 하단 조작부 (보상확인 / 홈)
              // ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: 보상 확인 화면
                      },
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: kPurple, width: 2),
                        padding:
                            const EdgeInsets.symmetric(vertical: 18),
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 18),
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
// 📊 _RecordItem: 기록 항목 위젯
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
