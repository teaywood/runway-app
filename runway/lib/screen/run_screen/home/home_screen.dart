// lib/screen/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import 'widgets/running_mode_toggle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RUN-WAY',
              style: TextStyle(
                color:         AppColors.textPrimary,
                fontWeight:    FontWeight.bold,
                fontSize:      22,
                letterSpacing: 2,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.directions_run_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            // ── 아바타 영역 (TODO: 추후 AvatarView 추가) ──
            Expanded(
              flex: 5,
              child: SizedBox.shrink(),
            ),
            // ── 러닝 모드 선택 영역 ─────────────────
            Expanded(
              flex: 3,
              child: RunningModeToggle(),
            ),
          ],
        ),
      ),
    );
  }
}
