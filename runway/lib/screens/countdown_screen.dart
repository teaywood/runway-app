import 'package:flutter/material.dart';
import 'dart:async';

// ═══════════════════════════════════════════════════════════
// ⏱️ COUNTDOWN SCREEN
// 홈 → 러닝 화면 사이 5초 카운트다운 (몰입감 UP)
// 5, 4, 3, 2, 1 → GO! → RunningScreen 자동 전환
// ═══════════════════════════════════════════════════════════
class CountdownScreen extends StatefulWidget {
  final Widget targetScreen;

  const CountdownScreen({super.key, required this.targetScreen});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  static const Color kPurple = Color(0xFF7C6BFF);

  int _count = 5; // 카운트 시작 숫자
  String _displayText = '5'; // 화면에 보여줄 텍스트
  Timer? _timer; // 1초마다 동작하는 타이머

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _count--;
        if (_count > 0) {
          // 5 → 4 → 3 → 2 → 1
          _displayText = '$_count';
        } else if (_count == 0) {
          // 마지막엔 GO! 표시
          _displayText = 'GO!';
        } else {
          // GO! 보여준 뒤 목적지 화면으로 이동
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => widget.targetScreen),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // 메모리 누수 방지: 화면 벗어나면 타이머 취소
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPurple, // 풀스크린 퍼플 배경
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            // 숫자 바뀔 때마다 확대 + 페이드인 애니메이션
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            _displayText,
            key: ValueKey<String>(_displayText), // key 필수! (애니메이션 트리거)
            style: TextStyle(
              color: Colors.white,
              fontSize: _displayText == 'GO!' ? 120 : 180,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
