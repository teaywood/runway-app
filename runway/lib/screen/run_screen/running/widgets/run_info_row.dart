// lib/screen/running/widgets/run_info_row.dart
import 'package:flutter/material.dart';

/// 거리 · 페이스 · 시간 3칸 정보 Row (두 화면 공통)
class RunInfoRow extends StatelessWidget {
  final String distance;
  final String pace;
  final String time;

  const RunInfoRow({
    super.key,
    required this.distance,
    required this.pace,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _InfoItem(value: distance, unit: 'km', label: '거리'),
        _InfoItem(value: pace, unit: '/km', label: '페이스'),
        _InfoItem(value: time, unit: 'time', label: '시간'),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

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
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D3A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
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
