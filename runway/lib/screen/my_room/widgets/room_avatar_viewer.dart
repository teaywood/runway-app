import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';

/// 마이룸 전신 아바타 뷰어
///
/// 책임:
///  - 2.5D 전신 아바타를 당당한 포즈로 렌더링
///  - 잦은 리페인트(애니메이션/액션버튼 갱신)로부터 격리하기 위해 RepaintBoundary 사용
///  - asset 미등록 환경에서도 컴파일/렌더 가능하도록 placeholder fallback 제공
class RoomAvatarViewer extends StatelessWidget {
  const RoomAvatarViewer({super.key, this.avatarAsset});

  /// 아바타 전신 이미지 asset 경로 (미지정 시 placeholder 표시)
  final String? avatarAsset;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 380,
        width: 220,
        child: avatarAsset == null
            ? const _AvatarPlaceholder()
            : Image.asset(
                avatarAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const _AvatarPlaceholder(),
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
