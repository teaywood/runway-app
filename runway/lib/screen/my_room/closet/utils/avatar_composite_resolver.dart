// lib/screen/my_room/closet/utils/avatar_composite_resolver.dart
import '../models/closet_models.dart';

/// 아바타 베이스(몸통) 에셋 — 항상 최하단 레이어 (order 0)
const String kAvatarBodyAsset = 'assets/images/my_room/avatar/avatar_full.png';

/// 합성 레이어 1개 정보
class AvatarLayer {
  const AvatarLayer({required this.assetPath, required this.order});

  final String assetPath;
  final int order;
}

/// 장착 맵 + 카탈로그 → z-order 정렬된 레이어 리스트로 변환
///
/// 책임: equipped(카테고리→아이템id)를 실제 착용 에셋(wearAsset) 레이어로
///       해석하고 z-order(오름차순)로 정렬해 반환
List<AvatarLayer> resolveAvatarLayers({
  required Map<ClosetCategory, String> equipped,
  required Map<ClosetCategory, List<ClosetItem>> catalog,
}) {
  final layers = <AvatarLayer>[
    // 베이스 바디는 항상 최하단
    const AvatarLayer(assetPath: kAvatarBodyAsset, order: 0),
  ];

  equipped.forEach((category, itemId) {
    final items = catalog[category];
    if (items == null) return;

    for (final item in items) {
      if (item.id == itemId) {
        layers.add(
          AvatarLayer(
            assetPath: item.wearAsset, // ⭐ 착용용 전신 PNG
            order: category.layerOrder,
          ),
        );
        break;
      }
    }
  });

  // z-order 오름차순 정렬 (작을수록 먼저 그려져 뒤에 깔림)
  layers.sort((a, b) => a.order.compareTo(b.order));
  return layers;
}

/// 🌸 [임시] 벚꽃 상의 → 완제품 통짜 이미지로 베이스 교체
class AvatarFullOverride {
  /// 완제품 이미지: avatar_full.png 와 "같은 폴더"의 avatar_ver2.png
  static final String _fullImagePath = kAvatarBodyAsset.replaceFirst(
    'avatar_full.png',
    'avatar_ver2.png',
  );
  // 결과: 'assets/images/my_room/avatar/avatar_ver2.png'

  /// 벚꽃 상의 식별 키워드 (여전히 layer 판단엔 필요)
  /// ⚠️ 벚꽃 반팔 아이템의 실제 fileName으로 맞춰주세요
  static const String _cherryTopFileName = 'c1_pink_cherryblossom_tshirts';

  /// 벚꽃 상의가 장착돼 있으면 완제품 경로, 아니면 null
  static String? resolveFromLayers(List<AvatarLayer> layers) {
    final hasCherryTop = layers.any(
      (layer) => layer.assetPath.contains(_cherryTopFileName),
    );
    return hasCherryTop ? _fullImagePath : null;
  }
}
