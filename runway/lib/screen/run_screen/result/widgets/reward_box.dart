// lib/screen/run_screen/result/widgets/reward_box.dart
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

// ═══════════════════════════════════════════════════════════
// 🎁 REWARD BOX
// 결과 화면에서 "보상확인" 버튼을 누르면 뜨는 오버레이 다이얼로그
// 스타일: CourseConditionDialog 와 동일 톤 (surface 배경 + radius 24)
// ═══════════════════════════════════════════════════════════
class RewardBox extends StatelessWidget {
  final String challengeTitle;
  final String itemImagePath;
  final String itemName;
  final VoidCallback? onConfirm;

  const RewardBox({
    super.key,
    required this.challengeTitle,
    required this.itemImagePath,
    this.itemName = '',
    this.onConfirm,
  });

  /// 편의 메서드: showDialog 호출을 한 줄로
  static void show(
    BuildContext context, {
    required String challengeTitle,
    required String itemImagePath,
    String itemName = '',
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55), // 딤 배경
      builder: (_) => RewardBox(
        challengeTitle: challengeTitle,
        itemImagePath:  itemImagePath,
        itemName:       itemName,
        onConfirm:      onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─────────────────────────────────────
            // 🏆 챌린지 달성 타이틀
            // ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      challengeTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─────────────────────────────────────
            // 🎽 획득 아이템 이미지
            // ─────────────────────────────────────
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.cardBorder.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  itemImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─────────────────────────────────────
            // 📝 아이템 이름 (옵션)
            // ─────────────────────────────────────
            if (itemName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // ─────────────────────────────────────
            // 💬 안내 문구
            // ─────────────────────────────────────
            Text(
              '새로운 아이템을 획득했습니다!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ─────────────────────────────────────
            // ✅ 확인 버튼
            // ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  onConfirm?.call();      // 추가 콜백 (아바타 화면 이동 등)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
