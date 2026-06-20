// lib/screen/my_room/closet/avatar_closet_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/selected_avatar_provider.dart';
import 'models/closet_models.dart';
import 'widgets/closet_avatar_viewer.dart';
import 'widgets/closet_category_menu.dart';
import 'widgets/closet_item_list.dart';
import 'widgets/closet_top_bar.dart';

import 'utils/avatar_composite_resolver.dart';

/// 배경 에셋 경로 (실제 경로로 교체)
const String kClosetBackgroundAsset = 'assets/images/my_room/my_room_bg.png';

/// 아바타 커스텀(꾸미기) 화면
///
/// 책임:
///  - Stack 기반 전체 레이아웃 조립 (배경 → 아바타 → UI 패널)
///  - 선택 카테고리 / 장착 아이템 상태 관리 후 하위로 콜백 위임
class AvatarClosetScreen extends StatefulWidget {
  const AvatarClosetScreen({super.key});

  @override
  State<AvatarClosetScreen> createState() => _AvatarClosetScreenState();
}

class _AvatarClosetScreenState extends State<AvatarClosetScreen> {
  /// 현재 선택된 카테고리
  ClosetCategory _selectedCategory = ClosetCategory.top;

  void _onCategorySelected(ClosetCategory category) {
    setState(() => _selectedCategory = category);
  }

  void _onItemEquip(ClosetItem item) {
    if (item.locked) return; // 미획득 아이템은 장착 불가
    
    // ✨ Provider에 업데이트 위임
    final provider = context.read<SelectedAvatarProvider>();
    provider.equipItem(_selectedCategory, item.id);
  }

  /// 현재 카테고리의 아이템 목록 (더미 데이터)
  List<ClosetItem> get _currentItems =>
      kDummyClosetItems[_selectedCategory] ?? const [];

  @override
  Widget build(BuildContext context) {
    // ✨ Provider에서 현재 장착 정보 읽기
    final provider = context.watch<SelectedAvatarProvider>();
    final String? equippedId = provider.getEquippedId(_selectedCategory);

    // ⭐ 현재 장착 상태(_equipped) → z-order 정렬된 합성 레이어 계산
    final avatarLayers = resolveAvatarLayers(
      equipped: provider.equipped,
      catalog: kDummyClosetItems,
    );

    return Scaffold(
      body: Stack(
        children: [
          // ── Layer 1. 전체 배경 ──
          Positioned.fill(
            child: Image.asset(
              kClosetBackgroundAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) =>
                  const ColoredBox(color: Color(0xFFF8F7FF)),
            ),
          ),

          // ── Layer 2. 중앙 아바타 (합성 레이어 전달) ──
          Positioned.fill(
            child: ClosetAvatarViewer(
              layers: avatarLayers,
            ),
          ),

          // ── Layer 3. 상단 바 (뒤로가기 + 재화) ──
          SafeArea(
            child: Column(
              children: [
                ClosetTopBar(
                  coin: 1250,
                  gem: 30,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
              ],
            ),
          ),

          // ── Layer 4. 우측 세로 카테고리 메뉴 ──
          SafeArea(
            child: Align(
              alignment: Alignment.centerRight,
              child: ClosetCategoryMenu(
                selected: _selectedCategory,
                onSelected: _onCategorySelected,
              ),
            ),
          ),

          // ── Layer 5. 하단 아이템 리스트 ──
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClosetItemList(
                items: _currentItems,
                equippedItemId: equippedId,
                onEquip: _onItemEquip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
