// lib/screen/my_room/closet/widgets/closet_category_menu.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../models/closet_models.dart';

/// 우측 세로 카테고리 메뉴 (글래스모피즘)
///
/// 책임: 카테고리 목록 표시 / 활성 탭 강조 / 선택 콜백 위임
class ClosetCategoryMenu extends StatelessWidget {
  const ClosetCategoryMenu({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ClosetCategory selected;
  final ValueChanged<ClosetCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ClosetCategory.values.map((category) {
                return _CategoryTab(
                  category: category,
                  active: category == selected,
                  onTap: () => onSelected(category),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// 단일 카테고리 탭
class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final ClosetCategory category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  category.icon,
                  size: 22,
                  color: active ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(height: 4),
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
