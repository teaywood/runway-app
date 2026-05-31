// lib/screen/running/widgets/run_map_area.dart
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

/// 공통 지도 영역 (mock).
/// [overlay]에 위젯을 넣으면 지도 중앙에 추가 표시됨 (예: AI 경로선 안내).
class RunMapArea extends StatelessWidget {
  final Widget? overlay;

  const RunMapArea({super.key, this.overlay});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  if (overlay != null) ...[
                    const SizedBox(height: 12),
                    overlay!,
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Course 전용: 지도 중앙에 표시되는 AI 경로선 안내 칩
class AiCourseChip extends StatelessWidget {
  const AiCourseChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '🤖 AI 코스 경로선 표시 영역',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
