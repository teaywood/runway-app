// lib/screen/loading/loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../shared/widgets/main_screen.dart';

/// 앱 최초 실행 시 표시되는 스플래시(로딩) 화면
///
/// [수정 사항]
/// 1. 배경색 → #F3EDFF
/// 2. 로고 정중앙 배치 + 1.5배 확대
/// 3. Loading 텍스트 → 하단 고정, 이탤릭, 순환 애니메이션
///    (CircularProgressIndicator 제거)
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // ─────────────────────────────────────────────────
  // 상태 변수
  // ─────────────────────────────────────────────────
  int _dotCount = 1;
  Timer? _dotTimer;
  Timer? _navigationTimer;

  // ─────────────────────────────────────────────────
  // 디자인 상수
  // ─────────────────────────────────────────────────
  static const Color _backgroundColor = Color(0xFFF3EDFF); // ✅ [수정1] 배경색 변경
  static const Color _textColor = Color(0xFF2D2D3A);        // 텍스트: 다크 계열
  static const String _logoPath = 'assets/images/logo.png';
  static const double _logoBaseSize = 120.0;
  static const double _logoScale = 1.5;                     // ✅ [수정2] 1.5배

  // ─────────────────────────────────────────────────
  // 생명주기
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

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1;
      });
    });
  }

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
      body: Stack(
        children: [
          // ═══════════════════════════════════════════
          // ✅ [수정2] 로고: 화면 정중앙 + 1.5배
          // ═══════════════════════════════════════════
          Center(
            child: Image.asset(
              _logoPath,
              width: _logoBaseSize * _logoScale,   // 120 × 1.5 = 180
              height: _logoBaseSize * _logoScale,
            ),
          ),

          // ═══════════════════════════════════════════
          // ✅ [수정3] Loading 텍스트: 하단 중앙, 이탤릭
          // ═══════════════════════════════════════════
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Loading${'.' * _dotCount}',
                style: TextStyle(
                  color: _textColor.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic, // 기울임
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
