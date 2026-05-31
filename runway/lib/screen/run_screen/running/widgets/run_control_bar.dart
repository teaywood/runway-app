// lib/screen/running/widgets/run_control_bar.dart
import 'package:flutter/material.dart';
import 'long_press_button.dart';
import '../../../../core/app_theme.dart';

/// 일시정지/재시작 + 종료 버튼을 묶은 하단 컨트롤 바 (두 화면 공통)
class RunControlBar extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPauseToggle;
  final VoidCallback onStop;

  const RunControlBar({
    super.key,
    required this.isPaused,
    required this.onPauseToggle,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: LongPressButton(
              onComplete: onPauseToggle,
              icon: isPaused ? Icons.play_arrow : Icons.pause,
              label: isPaused ? '재시작' : '일시정지',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LongPressButton(
              onComplete: onStop,
              icon: Icons.stop,
              label: '종료',
              color: const Color(0xFFE53E5E),
            ),
          ),
        ],
      ),
    );
  }
}
