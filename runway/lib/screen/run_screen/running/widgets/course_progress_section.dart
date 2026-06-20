// lib/screen/running/widgets/course_progress_section.dart
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

/// Course 전용: 진행률 프로그레스 바 + 남은 코스 거리 카드
class CourseProgressSection extends StatelessWidget {
  final double progressRate;      // 0.0 ~ 1.0
  final double remainingDistance; // km

  const CourseProgressSection({
    super.key,
    required this.progressRate,
    required this.remainingDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── 진행률 바 ──────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progressRate,
                  minHeight: 16,
                  backgroundColor: const Color(0xFFEDE9FF),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Course 전용: "남은 코스 거리" 강조 카드
class RemainingDistanceCard extends StatelessWidget {
  final double remainingDistance;

  const RemainingDistanceCard({super.key, required this.remainingDistance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '남은 코스 거리',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${remainingDistance.toStringAsFixed(2)} km',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
