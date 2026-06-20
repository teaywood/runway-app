// lib/shared/widgets/course_condition_dialog.dart
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../screen/run_screen/home/widgets/course_selection.dart';


class CourseConditionDialog extends StatefulWidget {
  const CourseConditionDialog({super.key});

  @override
  State<CourseConditionDialog> createState() => _CourseConditionDialogState();
}

class _CourseConditionDialogState extends State<CourseConditionDialog> {
  double _targetDistance = 5.0;
  String _courseType     = '편도';

  void _onDistanceChanged(double v) => setState(() => _targetDistance = v);
  void _onCourseTypeChanged(String? v) {
    if (v != null) setState(() => _courseType = v);
  }

  /// 다이얼로그 닫고 → 코스 선택 카루셀 화면으로 이동
  void _onConfirm() {
    Navigator.pop(context); // 다이얼로그 닫기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseSelectionScreen(
          targetDistance: _targetDistance,
          courseType:     _courseType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DialogTitle(),
            const SizedBox(height: 24),
            _DistanceSlider(
              value:     _targetDistance,
              onChanged: _onDistanceChanged,
            ),
            const SizedBox(height: 20),
            _CourseTypeSelector(
              value:     _courseType,
              onChanged: _onCourseTypeChanged,
            ),
            // ── 안심 코스 모드 삭제됨 (백엔드 기본 적용) ──
            const SizedBox(height: 28),
            _ConfirmButton(onPressed: _onConfirm),
          ],
        ),
      ),
    );
  }
}

// ── 서브 위젯 분리 (Dialog 내부 전용) ───────────────────────

class _DialogTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      '맞춤형 코스 설정',
      style: TextStyle(
        fontSize:   22,
        fontWeight: FontWeight.bold,
        color:      AppColors.primary,
      ),
    );
  }
}

class _DistanceSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _DistanceSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '목표 거리: ${value.toStringAsFixed(1)} km',
          style: const TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:   AppColors.primary,
            inactiveTrackColor: AppColors.cardBorder,
            thumbColor:         AppColors.primary,
            overlayColor:       AppColors.primary.withOpacity(0.15),
          ),
          child: Slider(
            value:     value,
            min:       1.0,
            max:       20.0,
            divisions: 19,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _CourseTypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _CourseTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '코스 형태',
          style: TextStyle(
            fontSize:   16,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
        Row(
          children: ['편도', '왕복'].map((type) {
            return Expanded(
              child: RadioListTile<String>(
                title: Text(
                  type,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                value:          type,
                groupValue:     value,
                activeColor:    AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged:      onChanged,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ConfirmButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          '코스 생성',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
