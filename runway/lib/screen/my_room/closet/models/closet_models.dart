// lib/screen/my_room/closet/models/closet_models.dart
import 'package:flutter/material.dart';

/// 아이템 획득 경로 (일반 / 챌린지 보상)
enum AcquireType {
  normal, // n: 기본 제공
  challenge, // c: 챌린지 보상
}

/// 꾸미기 카테고리 (+ 레이어 z-order + 에셋 폴더명)
enum ClosetCategory {
  // label, icon, layerOrder(작을수록 아래), folder(에셋 경로용)
  hair('헤어', Icons.face_retouching_natural, 50, 'hair'),
  top('상의', Icons.checkroom, 40, 'top'),
  bottom('하의', Icons.dry_cleaning, 20, 'bottom'),
  shoes('신발', Icons.ice_skating, 30, 'shoes'),
  accessory('장신구', Icons.diamond_outlined, 60, 'accessory');

  const ClosetCategory(this.label, this.icon, this.layerOrder, this.folder);

  final String label;
  final IconData icon;

  /// 아바타 합성 시 겹치는 순서 (오름차순 → 작을수록 뒤로 깔림)
  final int layerOrder;

  /// 에셋 경로에 쓰이는 폴더명 (items/{folder}/...)
  final String folder;
}

/// 꾸미기 아이템 1개
///
/// 책임: id/이름/카테고리/파일명만 보유하고,
///       썸네일·착용 에셋 경로는 게터로 자동 생성 (입력 최소화)
class ClosetItem {
  const ClosetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.fileName, // thumb/wear 공통 파일명 (확장자 제외)
    this.acquireType = AcquireType.normal,
    this.locked = false,
  });

  final String id;
  final String name;
  final ClosetCategory category;

  /// 확장자 없는 공통 파일명 (예: 'n1_black_shorts')
  final String fileName;

  final AcquireType acquireType;
  final bool locked;

  /// 에셋 루트
  static const String _root = 'assets/images/my_room/items';

  /// 목록용 썸네일 경로 (자동 생성)
  String get thumbnailAsset => '$_root/${category.folder}/thumb/$fileName.png';

  /// 아바타 합성용 착용 경로 (자동 생성)
  String get wearAsset => '$_root/${category.folder}/wear/$fileName.png';

  /// 챌린지 보상 아이템 여부 (UI에서 트로피 배지용)
  bool get isChallenge => acquireType == AcquireType.challenge;
}

// lib/screen/my_room/closet/models/closet_models.dart (하단에 추가) 또는 별도 data 파일

final Map<ClosetCategory, List<ClosetItem>> kDummyClosetItems = {
  ClosetCategory.hair: [
    ClosetItem(
      id: 'hair_n1_half_up',
      name: '반묶음',
      category: ClosetCategory.hair,
      fileName: 'n1_half_up',
    ),
  ],
  ClosetCategory.top: [
    ClosetItem(
      id: 'top_n1_white_wind_jacket',
      name: '바람막이',
      category: ClosetCategory.top,
      fileName: 'n1_white_wind_jacket',
    ),
    ClosetItem(
      id: 'top_c1_pink_cherryblossom_tshirts',
      name: '벚꽃 반팔',
      category: ClosetCategory.top,
      fileName: 'c1_pink_cherryblossom_tshirts',
      acquireType: AcquireType.challenge, // ⭐ 챌린지 보상
    ),
  ],
  ClosetCategory.bottom: [
    ClosetItem(
      id: 'bottom_n1_black_shorts',
      name: '스포츠 반바지',
      category: ClosetCategory.bottom,
      fileName: 'n1_black_shorts',
    ),
  ],
  ClosetCategory.shoes: [
    ClosetItem(
      id: 'shoes_n1_lavender_sneakers',
      name: '라벤더 운동화',
      category: ClosetCategory.shoes,
      fileName: 'n1_lavender_sneakers',
    ),
  ],
  ClosetCategory.accessory: [
    ClosetItem(
      id: 'accessory_n1_black_hairpin',
      name: '검정 헤어핀',
      category: ClosetCategory.accessory,
      fileName: 'n1_black_hairpin',
    ),
  ],
};
