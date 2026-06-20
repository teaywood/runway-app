// lib/screen/run_screen/running/widgets/run_map_area.dart
import 'package:flutter/material.dart';

/// 공통 지도 영역 (mock).
/// [courseImagePath]가 주어지면 해당 코스 이미지를 표시.
class RunMapArea extends StatelessWidget {
  final String? courseImagePath;

  const RunMapArea({super.key, this.courseImagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                  errorBuilder: (_, __, ___) => _MapPlaceholder(),
                )
              : _MapPlaceholder(),
        ),
      ),
    );
  }
}

/// 이미지 없을 때 기본 플레이스홀더
class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🗺️ MAP AREA',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 2,
        ),
      ),
    );
  }
}
