import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';

/// 메달 / 트로피 전시룸(장식장) 화면 — Stub
class TrophyRoomScreen extends StatelessWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roomBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('장식장', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: const Center(
        child: Text(
          '메달 / 트로피 전시룸 (준비 중)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
