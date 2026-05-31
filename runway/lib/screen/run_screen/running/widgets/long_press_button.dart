// lib/screen/running/widgets/long_press_button.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// 🎯 LongPressButton — 꾹 눌러서 실행되는 버튼 (단일화 버전)
/// ───────────────────────────────────────────────────────────
/// • [holdDuration]만큼 누르고 있으면 [onComplete] 호출
/// • 테두리를 따라 진행도 애니메이션 표시
/// • Flutter Web(dart2js) 호환: onLongPressDown 람다 인라인 처리
/// ═══════════════════════════════════════════════════════════
class LongPressButton extends StatefulWidget {
  final VoidCallback onComplete;
  final IconData icon;
  final String label;
  final Color color;
  final Duration holdDuration;

  const LongPressButton({
    super.key,
    required this.onComplete,
    required this.icon,
    required this.label,
    required this.color,
    this.holdDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<LongPressButton> createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.holdDuration, vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() => _controller.forward();
  void _cancel() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // ⚠️ dart2js 호환: 별도 메서드(Details 타입) 대신 람다 인라인
      onLongPressDown: (_) => _start(),
      onLongPressUp: () => _cancel(),
      onLongPressCancel: () => _cancel(),
      child: Stack(
        children: [
          // 레이어 1: 버튼 본체
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // 레이어 2: 테두리 진행도 (터치 무시)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _BorderProgressPainter(
                    progress: _controller.value,
                    borderRadius: 16,
                    strokeWidth: 4,
                    color: const Color(0xFF00E5CC),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 테두리를 따라 진행도를 그리는 페인터
class _BorderProgressPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double strokeWidth;
  final Color color;

  const _BorderProgressPainter({
    required this.progress,
    required this.borderRadius,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final fullPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    final ui.PathMetrics metrics = fullPath.computeMetrics();
    if (metrics.isEmpty) return;

    final ui.PathMetric metric = metrics.first;
    final drawPath = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(_BorderProgressPainter old) => old.progress != progress;
}
