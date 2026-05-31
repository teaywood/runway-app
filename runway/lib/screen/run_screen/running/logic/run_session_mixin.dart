// lib/screen/running/logic/run_session_mixin.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// 🏃 RunSessionMixin
/// ───────────────────────────────────────────────────────────
/// 러닝 세션의 "공통 로직"을 담는 Mixin.
/// 타이머, 누적 거리, 일시정지 상태, 포맷팅 헬퍼를 제공한다.
///
/// 사용법:
///   class _MyScreenState extends State<MyScreen>
///       with RunSessionMixin<MyScreen> { ... }
///
///   initState()에서 startSession() 호출,
///   dispose()에서 stopSession() 호출.
/// ═══════════════════════════════════════════════════════════
mixin RunSessionMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;

  // ── 세션 상태 (서브클래스에서 읽기 전용 접근) ──────
  int _seconds = 0;
  double _distance = 0.0;
  bool _isPaused = false;

  int get seconds => _seconds;
  double get distance => _distance;
  bool get isPaused => _isPaused;

  // ── 시뮬레이션 속도 (약 2.8m/s) ───────────────────
  static const double _speedPerTick = 0.0028;

  /// 타이머 시작 — initState에서 호출
  void startSession() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (!_isPaused) {
          _seconds++;
          _distance += _speedPerTick;
        }
      });
    });
  }

  /// 일시정지 ↔ 재시작 토글
  void togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  /// 타이머 정지 — 종료 시 호출
  void stopSession() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopSession();
    super.dispose();
  }

  // ── 포맷 헬퍼 ─────────────────────────────────────
  String get formattedTime {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedDistance => _distance.toStringAsFixed(2);

  String get formattedPace {
    if (_distance == 0) return "0'00\"";
    final paceMinutes = _seconds / 60 / _distance;
    final m = paceMinutes.floor();
    final s = ((paceMinutes - m) * 60).round();
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  String get estimatedCalories => (_distance * 60).round().toString();
}
