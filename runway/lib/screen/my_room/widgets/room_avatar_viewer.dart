import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../providers/selected_avatar_provider.dart';
import '../closet/models/closet_models.dart';
import '../closet/utils/avatar_composite_resolver.dart';
import '../closet/widgets/closet_avatar_viewer.dart';

/// 마이룸 전신 아바타 뷰어
///
/// 책임:
///  - SelectedAvatarProvider에서 현재 착용 아이템을 읽어 전신 아바타 렌더링
///  - 잦은 리페인트(애니메이션/액션버튼 갱신)로부터 격리하기 위해 RepaintBoundary 사용
///  - 아바타 레이어가 비어 있을 경우 placeholder fallback 제공
class RoomAvatarViewer extends StatelessWidget {
  const RoomAvatarViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 380,
        width: 220,
        child: Consumer<SelectedAvatarProvider>(
          builder: (context, avatarProvider, child) {
            // ✅ HomeScreen과 동일한 호출 방식
            final layers = resolveAvatarLayers(
              equipped: avatarProvider.equipped,
              catalog: kDummyClosetItems,
            );

            if (layers.isEmpty) {
              return const _AvatarPlaceholder();
            }

            return ClosetAvatarViewer(layers: layers);
          },
        ),
      ),
    );
  }
}

/// asset 등록 전까지 사용하는 전신 실루엣 placeholder
class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_run,
            size: 56,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AVATAR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: AppColors.textPrimary.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
