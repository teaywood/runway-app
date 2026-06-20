// lib/providers/selected_avatar_provider.dart
import 'package:flutter/material.dart';
import '../screen/my_room/closet/models/closet_models.dart';

/// 아바타 커스텀 상태를 전역으로 관리하는 Provider
///
/// 책임:
///  - 전체 앱에서 "현재 선택된 아이템들"(장착 중) 추적
///  - 마이룸 → 홈 화면 동기화
class SelectedAvatarProvider extends ChangeNotifier {
  /// 카테고리별 현재 장착(착용 중) 아이템 id
  final Map<ClosetCategory, String> _equipped = {
    ClosetCategory.hair: 'hair_n1_half_up',
    ClosetCategory.top: 'top_n1_basic_tshirts',
    ClosetCategory.bottom: 'bottom_n1_basic_bottom',
    ClosetCategory.shoes: 'shoes_n1_basic_sneakers',
    ClosetCategory.accessory: 'accessory_n1_no_accessory',
  };

  /// 현재 장착 아이템들 조회 (읽기 전용)
  Map<ClosetCategory, String> get equipped => Map.unmodifiable(_equipped);

  /// 특정 카테고리 아이템 장착
  void equipItem(ClosetCategory category, String itemId) {
    _equipped[category] = itemId;
    notifyListeners(); // ✨ 모든 구독자에게 알림
  }

  /// 특정 카테고리의 현재 장착 ID 조회
  String? getEquippedId(ClosetCategory category) => _equipped[category];
}
