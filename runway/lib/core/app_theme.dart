// lib/core/app_theme.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Background & Surface ──────────────────────────
  static const Color background   = Color(0xFFF8F7FF); // Soft Lavender White
  static const Color surface      = Color(0xFFFFFFFF); // Pure White

  // ── Brand ─────────────────────────────────────────
  static const Color primary      = Color(0xFF7C6BFF); // Deep Lavender
  static const Color secondary    = Color(0xFFB8A9FF); // Light Lavender

  // ── Text ──────────────────────────────────────────
  static const Color textPrimary  = Color(0xFF2D2D3A); // Dark Charcoal
  static const Color textSecondary= Color(0xFF8E8E93); // Cool Gray

  // ── Semantic ──────────────────────────────────────
  static const Color white        = Color(0xFFFFFFFF);
  static const Color cardBorder   = Color(0xFFE8E4FF); // 연라벤더 테두리

  // ─── My Room Surface ───
  static const Color roomBackground = Color(0xFFF8F7FF); // Soft Lavender White

  // ─── Text ───
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Room Stage (런웨이 트랙 공간감) ───
  static const Color stageGlowTop = Color(0xFFFFFFFF);
  static const Color stageGlowMid = Color(0xFFF1EEFF);
  static const Color stageFloor = Color(0xFFE7E2FF);
  static const Color shadowSoft = Color(0x1A2D2D3A);
}

abstract class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    fontFamily: 'Pretendard',
    colorScheme: const ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      surface:   AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor:  Colors.transparent,
      elevation:        0,
      centerTitle:      true,
      foregroundColor:  AppColors.textPrimary,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.surface,
      selectedItemColor:    AppColors.primary,
      unselectedItemColor:  AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
