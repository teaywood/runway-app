// lib/screen/my_room/closet/widgets/closet_item_list.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../models/closet_models.dart';

/// 장착 중 강조 컬러 (이미지의 초록 테두리)
const Color kEquippedColor = Color(0xFF22C55E);

/// 하단 아이템 리스트 패널 (글래스모피즘)
///
/// 책임: 현재 카테고리 아이템 가로 스크롤 표시 / 장착·잠금 상태 시각화 / 장착 콜백
class ClosetItemList extends StatelessWidget {
  const ClosetItemList({
    super.key,
    required this.items,
    required this.equippedItemId,
    required this.onEquip,
  });

  final List<ClosetItem> items;
  final String? equippedItemId;
  final ValueChanged<ClosetItem> onEquip;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.32),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ItemCard(
                  item: item,
                  equipped: item.id == equippedItemId,
                  onTap: () => onEquip(item),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 단일 아이템 카드 (썸네일 + 장착중/미획득 배지)
class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.equipped,
    required this.onTap,
  });

  final ClosetItem item;
  final bool equipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = equipped
        ? kEquippedColor
        : Colors.white.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // 썸네일 카드
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor,
                        width: equipped ? 2.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        item.thumbnailAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stackTrace) => const Icon(
                          Icons.checkroom_rounded,
                          size: 40,
                          color: Color(0x552D2D3A),
                        ),
                      ),
                    ),
                  ),

                  // 잠금(미획득) 오버레이
                  if (item.locked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '미획득',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 착용 중 배지
                  if (equipped)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kEquippedColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '착용 중',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
