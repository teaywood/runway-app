// lib/screen/loading/loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets/main_screen.dart';

/// 앱 최초 실행 시 표시되는 스플래시(로딩) 화면
/// 
/// [기능]
/// - 중앙에 로고 이미지 표시
/// - 하단에 원형 로딩 인디케이터 + 주기적으로 변경되는 텍스트 애니메이션
/// - 2초 후 자동으로 메인 화면(MainScreen)으로 전환
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // ─────────────────────────────────────────────────
  // 상태 변수
  // ─────────────────────────────────────────────────
  int _dotCount = 1; // 로딩 텍스트의 점(.) 개수 (1~3 순환)
  Timer? _dotTimer;  // 텍스트 애니메이션용 타이머
  Timer? _navigationTimer; // 화면 전환용 타이머

  // ─────────────────────────────────────────────────
  // 디자인 상수
  // ─────────────────────────────────────────────────
  static const Color _backgroundColor = AppColors.primary; // 배경: 브랜드 메인 컬러
  static const Color _loaderColor = AppColors.white;       // 로딩 인디케이터: 흰색
  static const Color _textColor = AppColors.white;         // 텍스트: 흰색
  static const String _logoPath = 'assets/images/logo.png'; // 로고 경로
  static const double _logoSize = 120.0;                    // 로고 크기
  static const double _loaderSize = 32.0;                   // 인디케이터 지름
  static const double _spacing = 24.0;                      // 로고 ↔ 로더 간격

  // ─────────────────────────────────────────────────
  // 생명주기: 초기화
  // ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _scheduleNavigation();
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────
  // 로직: 텍스트 애니메이션 (loading. → loading.. → loading...)
  // ─────────────────────────────────────────────────
  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1; // 1 → 2 → 3 → 1 순환
      });
    });
  }

  // ─────────────────────────────────────────────────
  // 로직: 2초 후 메인 화면으로 자동 전환
  // ─────────────────────────────────────────────────
  void _scheduleNavigation() {
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  // ─────────────────────────────────────────────────
  // UI 빌드
  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── 로고 이미지 (아바타 방식과 동일) ───
            Image.asset(
              _logoPath,
              width: _logoSize,
              height: _logoSize,
            ),

            const SizedBox(height: _spacing * 2),

            // ─── 로딩 인디케이터 ───
            SizedBox(
              width: _loaderSize,
              height: _loaderSize,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: const AlwaysStoppedAnimation<Color>(_loaderColor),
              ),
            ),

            const SizedBox(height: _spacing),

            // ─── 로딩 텍스트 (애니메이션) ───
            Text(
              'loading${'.' * _dotCount}',
              style: const TextStyle(
                color: _textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
