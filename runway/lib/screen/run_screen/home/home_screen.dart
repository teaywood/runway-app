// lib/screen/run_screen/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../providers/selected_avatar_provider.dart';
import '../../my_room/closet/models/closet_models.dart';
import '../../my_room/closet/utils/avatar_composite_resolver.dart';
import '../../my_room/closet/widgets/closet_avatar_viewer.dart';
import 'widgets/running_mode_toggle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // ═══════════════════════════════════════════════
        // ✅ [수정] title 중앙 정렬
        // ═══════════════════════════════════════════════
        centerTitle: true,
        leadingWidth: 0,
        leading: const SizedBox.shrink(), // leading 영역 제거 → 좌우 대칭
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RUN-WAY',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 22,
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
            // ── ✨ 아바타 영역 (이제 활성화!) ──
            Expanded(
              flex: 5,
              child: _HomeAvatarSection(),
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

/// 홈 화면 아바타 섹션 (Provider 구독)
class _HomeAvatarSection extends StatelessWidget {
  const _HomeAvatarSection();

  @override
  Widget build(BuildContext context) {
    // ✨ Provider 구독: 마이룸에서 선택한 아이템 자동 반영
    final provider = context.watch<SelectedAvatarProvider>();

    final avatarLayers = resolveAvatarLayers(
      equipped: provider.equipped,
      catalog: kDummyClosetItems,
    );

    return ClosetAvatarViewer(layers: avatarLayers);
  }
}
