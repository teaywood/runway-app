// lib/screen/countdown/countdown_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

/// ═══════════════════════════════════════════════════════════
/// ⏱️ COUNTDOWN SCREEN
/// ───────────────────────────────────────────────────────────
/// 홈 → 러닝 화면 사이의 5초 카운트다운 게이트.
/// 5 → 4 → 3 → 2 → 1 → GO! 순으로 표시 후
/// [targetScreen]으로 자동 전환된다.
///
/// 사용 예:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => const CountdownScreen(
///       targetScreen: RunningScreen(),
///     ),
///   ));
/// ═══════════════════════════════════════════════════════════
class CountdownScreen extends StatefulWidget {
  /// 카운트다운 종료 후 이동할 목적지 화면
  final Widget targetScreen;

  const CountdownScreen({
    super.key,
    required this.targetScreen,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  // ── 카운트다운 설정값 ─────────────────────────────
  static const int _startFrom = 5;
  static const Duration _tickInterval = Duration(seconds: 1);
  static const Duration _switchAnimDuration = Duration(milliseconds: 400);

  // ── 폰트 크기 ────────────────────────────────────
  static const double _numberFontSize = 180;
  static const double _goFontSize     = 120;

  // ── 상태 ─────────────────────────────────────────
  int _count = _startFrom;
  String _displayText = '$_startFrom';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    // 메모리 누수 방지: 화면 벗어나면 타이머 취소
    _timer?.cancel();
    super.dispose();
  }

  /// 1초마다 카운트를 감소시키고, 0이 되면 "GO!" 표시 후 화면 전환
  void _startCountdown() {
    _timer = Timer.periodic(_tickInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _count--;
        if (_count > 0) {
          _displayText = '$_count';     // 5 → 4 → 3 → 2 → 1
        } else if (_count == 0) {
          _displayText = 'GO!';         // 마지막 신호
        } else {
          timer.cancel();
          _navigateToTarget();
        }
      });
    });
  }

  void _navigateToTarget() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGoFrame = _displayText == 'GO!';

    return Scaffold(
      backgroundColor: AppColors.primary, // ✅ 매직 넘버 제거
      body: Center(
        child: AnimatedSwitcher(
          duration: _switchAnimDuration,
          transitionBuilder: (child, animation) {
            // 숫자 바뀔 때마다 확대 + 페이드인
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            _displayText,
            key: ValueKey<String>(_displayText), // ⚠️ key 필수 (애니메이션 트리거)
            style: TextStyle(
              color:         AppColors.white,
              fontSize:      isGoFrame ? _goFontSize : _numberFontSize,
              fontWeight:    FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
