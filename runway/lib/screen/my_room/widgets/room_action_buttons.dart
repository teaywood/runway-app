import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';

/// 마이룸 하단 액션 버튼 그룹
///
/// 책임:
///  - [꾸미기] / [장식장] 두 핵심 액션 버튼 배치
///  - 네비게이션은 상위(MyRoomScreen)에서 주입한 콜백으로 위임 (라우팅 의존성 분리)
class RoomActionButtons extends StatelessWidget {
  const RoomActionButtons({
    super.key,
    required this.onTapDressUp,
    required this.onTapTrophy,
  });

  final VoidCallback onTapDressUp;
  final VoidCallback onTapTrophy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _RoomActionButton(
              icon: Icons.checkroom_rounded,
              label: '꾸미기',
              filled: true,
              onTap: onTapDressUp,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _RoomActionButton(
              icon: Icons.emoji_events_rounded,
              label: '장식장',
              filled: false,
              onTap: onTapTrophy,
            ),
          ),
        ],
      ),
    );
  }
}

/// 단일 액션 버튼 (filled: 강조형 / outlined: 보조형)
class _RoomActionButton extends StatelessWidget {
  const _RoomActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = filled ? AppColors.primary : AppColors.surface;
    final Color foreground = filled
        ? AppColors.textOnPrimary
        : AppColors.textPrimary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      elevation: filled ? 6 : 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: filled
                ? null
                : Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
