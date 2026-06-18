import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roomBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // // ── Layer 1. 런웨이 트랙 공간감 배경 ──
            // const Positioned.fill(child: _RoomStageBackground()),

            // // ── Layer 2. 전신 아바타 전시 ──
            // const Positioned.fill(
            //   child: Align(
            //     alignment: Alignment(0, -0.15),
            //     child: RoomAvatarViewer(),
            //   ),
            // ),

            // ── Layer 3. 상단 타이틀 ──
            const Positioned(top: 16, left: 24, child: _RoomHeader()),

            // ── Layer 4. 하단 액션 버튼 ──
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 28,
            //   child: RoomActionButtons(
            //     onTapDressUp: () => _openCloset(context),
            //     onTapTrophy: () => _openTrophyRoom(context),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

/// 런웨이 트랙 느낌의 3D 공간감 배경 (Soft Light + Gradient)
// class _RoomStageBackground extends StatelessWidget {
//   const _RoomStageBackground();

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             AppColors.stageGlowTop,
//             AppColors.stageGlowMid,
//             AppColors.roomBackground,
//           ],
//           stops: [0.0, 0.55, 1.0],
//         ),
//       ),
//       child: Stack(
//         children: [
//           // 중앙 스포트라이트 (Soft Light)
//           Align(
//             alignment: const Alignment(0, -0.2),
//             child: Container(
//               width: 320,
//               height: 320,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [AppColors.stageGlowTop, AppColors.stageGlowMid],
//                   stops: [0.2, 1.0],
//                 ),
//               ),
//             ),
//           ),

//           // 바닥 런웨이 트랙 (타원형 무대)
//           Align(
//             alignment: const Alignment(0, 0.62),
//             child: Container(
//               width: 280,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: AppColors.stageFloor,
//                 borderRadius: BorderRadius.circular(140),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: AppColors.shadowSoft,
//                     blurRadius: 40,
//                     spreadRadius: 4,
//                     offset: Offset(0, 12),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

/// 상단 타이틀 헤더
class _RoomHeader extends StatelessWidget {
  const _RoomHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOCIAL',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          '소셜 커뮤니티',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
