// lib/screen/my_room/closet/widgets/closet_avatar_viewer.dart
import 'package:flutter/material.dart';

import '../utils/avatar_composite_resolver.dart';

/// 꾸미기 화면 중앙 아바타 뷰어 (레이어 합성)
///
/// 책임: 전달받은 레이어들을 z-order대로 Stack에 겹쳐 렌더링 (RepaintBoundary 격리)
class ClosetAvatarViewer extends StatelessWidget {
  const ClosetAvatarViewer({super.key, required this.layers});

  final List<AvatarLayer> layers;

  @override
  Widget build(BuildContext context) {
    // 🚧 [임시] 레이어 합성 OFF — 베이스 한 장만 그리되,
    //    벚꽃 상의 장착 여부에 따라 완제품/기본 이미지 전환.
    final overridePath = AvatarFullOverride.resolveFromLayers(layers);

    // 벚꽃이면 avatar_ver2.png, 아니면 기본 avatar_full.png
    final basePath = overridePath ?? kAvatarBodyAsset;

    // ═══════════════════════════════════════════════════
    // ✅ [수정] 정렬 기준: 하단 중앙 (bottomCenter)
    //
    // 이전: Alignment(-0.25, -0.05) → 이미지 중심 기준 수동 오프셋
    // 수정: bottomCenter → 아바타 발 위치를 앵커로 잡아
    //       수평 중앙 + 수직 바닥 기준 정렬
    // ═══════════════════════════════════════════════════
    return Align(
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        basePath,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter, // 이미지 내부 정렬도 하단 중앙
        errorBuilder: (c, e, s) => const Center(
          child: Text('이미지 로드 실패', style: TextStyle(color: Colors.red)),
        ),
      ),
    );

    /* 🧩 [나중에 복구] 레이어 합성 원본
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        for (final layer in layers)
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              layer.assetPath,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
      ],
    );
    */
  }
}
