// lib/screen/my_room/closet/widgets/closet_top_bar.dart
import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';

/// 꾸미기 화면 상단 바 (투명 + 글래스 칩)
///
/// 책임: 뒤로가기 버튼 / 보유 재화(coin, gem) 표시
class ClosetTopBar extends StatelessWidget {
  const ClosetTopBar({
    super.key,
    required this.coin,
    required this.gem,
    required this.onBack,
  });

  final int coin;
  final int gem;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _GlassCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const Spacer(),
          _CurrencyChip(
            icon: Icons.monetization_on_rounded,
            value: coin,
            iconColor: const Color(0xFFFFC93C),
          ),
          const SizedBox(width: 8),
          _CurrencyChip(
            icon: Icons.diamond_rounded,
            value: gem,
            iconColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

/// 글래스 원형 버튼
class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// 재화 표시 칩 (글래스)
class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final int value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
