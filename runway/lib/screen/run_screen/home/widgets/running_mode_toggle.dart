// lib/screen/home/widgets/running_mode_toggle.dart
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../shared/widgets/course_condition_dialog.dart';
import '../../countdown/countdown_screen.dart'; // ◀━━ 추가
import '../../running/running_screen.dart'; // ◀━━ 추가


// ── 러닝 모드 카드 데이터 모델 ─────────────────────────────
class _ModeCardData {
  final String   label;
  final IconData icon;
  final Color    accentColor;
  const _ModeCardData({
    required this.label,
    required this.icon,
    required this.accentColor,
  });
}

class RunningModeToggle extends StatelessWidget {
  const RunningModeToggle({super.key});

  static const _modes = [
    _ModeCardData(
      label:       '달리기',
      icon:        Icons.directions_run_rounded,
      accentColor: AppColors.primary,
    ),
    _ModeCardData(
      label:       '코스 달리기',
      icon:        Icons.route_rounded,
      accentColor: AppColors.secondary,
    ),
  ];

  void _onModeTapped(BuildContext context, int index) {
    if (index == 0) {
      _startFreeRun(context);
    } else {
      _openCourseDialog(context);
    }
  }

  // 일반 달리기 → 카운트다운 → 러닝 화면
  void _startFreeRun(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CountdownScreen(targetScreen: RunningScreen()),
      ),
    );
  }

  // 코스 달리기 → 코스 설정 다이얼로그
  void _openCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CourseConditionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: List.generate(_modes.length, (i) {
          final mode = _modes[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 1 ? 12 : 0),
              child: _ModeCard(
                data:    mode,
                onTap:   () => _onModeTapped(context, i),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── 단일 모드 카드 위젯 ──────────────────────────────────────
class _ModeCard extends StatelessWidget {
  final _ModeCardData data;
  final VoidCallback  onTap;

  const _ModeCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: data.accentColor.withOpacity(0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:      data.accentColor.withOpacity(0.10),
              blurRadius: 14,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  52,
              height: 52,
              decoration: BoxDecoration(
                color:       data.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(data.icon, size: 28, color: data.accentColor),
            ),
            const SizedBox(height: 10),
            Text(
              data.label,
              style: TextStyle(
                fontSize:   15,
                fontWeight: FontWeight.w700,
                color:      data.accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
