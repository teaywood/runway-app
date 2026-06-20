// lib/screen/run_screen/running/widgets/run_map_area.dart
import 'dart:math';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// 🗺️ RUN MAP AREA — 코스 이미지 + 실시간 경로 트래킹
/// ═══════════════════════════════════════════════════════════

/// 코스별 더미 경로 데이터 (비율 좌표 0.0~1.0)
const Map<String, List<Offset>> kCourseRoutes = {
  'assets/images/course_2.png': [
    Offset(0.48, 0.33), // START (여의나루역)
    Offset(0.47, 0.35),
    Offset(0.45, 0.38),
    Offset(0.43, 0.41),
    Offset(0.41, 0.43),
    Offset(0.39, 0.46),
    Offset(0.37, 0.49),
    Offset(0.35, 0.52),
    Offset(0.32, 0.56),
    Offset(0.30, 0.59),
    Offset(0.28, 0.63),
    Offset(0.26, 0.67),
    Offset(0.29, 0.71),
    Offset(0.33, 0.75),
    Offset(0.37, 0.79),
    Offset(0.42, 0.83),
    Offset(0.47, 0.87),
    Offset(0.53, 0.91),
    Offset(0.58, 0.94),
    Offset(0.65, 0.96), // FINISH
  ],
};

class RunMapArea extends StatelessWidget {
  final String courseImagePath;

  /// 0.0 ~ 1.0 — 전체 경로 중 현재까지 진행된 비율
  final double trackingProgress;

  const RunMapArea({
    super.key,
    this.courseImagePath = '',
    this.trackingProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final route = kCourseRoutes[courseImagePath];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: 코스 이미지 ──
          if (courseImagePath.isNotEmpty)
            Image.asset(
              courseImagePath,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: const Color(0xFFF0F0F0),
              child: const Center(
                child: Text(
                  '🗺️ MAP AREA',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ),

          // ── Layer 2: 경로 트래킹 오버레이 ──
          if (route != null && trackingProgress > 0)
            CustomPaint(
              painter: _RouteTrackingPainter(
                fullRoute: route,
                progress: trackingProgress,
              ),
            ),
        ],
      ),
    );
  }
}

/// ─── CustomPainter: 경로선 + 글로우 dot ───
class _RouteTrackingPainter extends CustomPainter {
  final List<Offset> fullRoute;
  final double progress; // 0.0 ~ 1.0

  _RouteTrackingPainter({
    required this.fullRoute,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fullRoute.length < 2 || progress <= 0) return;

    // ── 비율 좌표 → 실제 픽셀 좌표 변환 ──
    final points = fullRoute
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    // ── 현재까지 그릴 점 개수 ──
    final totalSegments = points.length - 1;
    final progressIndex = progress * totalSegments;
    final completedIndex = progressIndex.floor();
    final segmentFraction = progressIndex - completedIndex;

    // ── 그릴 점 리스트 구성 ──
    final drawPoints = <Offset>[];
    for (int i = 0; i <= min(completedIndex, totalSegments); i++) {
      drawPoints.add(points[i]);
    }

    // 마지막 세그먼트 보간 (부드러운 진행)
    if (completedIndex < totalSegments) {
      final from = points[completedIndex];
      final to = points[completedIndex + 1];
      final interpolated = Offset(
        from.dx + (to.dx - from.dx) * segmentFraction,
        from.dy + (to.dy - from.dy) * segmentFraction,
      );
      drawPoints.add(interpolated);
    }

    if (drawPoints.length < 2) return;

    // ── 경로선 (검은색) ──
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(drawPoints[0].dx, drawPoints[0].dy);
    for (int i = 1; i < drawPoints.length; i++) {
      path.lineTo(drawPoints[i].dx, drawPoints[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // ── 현재 위치: 글로우 dot ──
    final currentPos = drawPoints.last;

    // 외곽 글로우 (큰 원, 반투명)
    final glowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(currentPos, 14, glowPaint);

    // 중간 링
    final midPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(currentPos, 8, midPaint);

    // 중심 dot (흰 테두리 + 검정 코어)
    final outerDot = Paint()..color = Colors.white;
    canvas.drawCircle(currentPos, 7, outerDot);

    final innerDot = Paint()..color = Colors.black;
    canvas.drawCircle(currentPos, 5, innerDot);
  }

  @override
  bool shouldRepaint(covariant _RouteTrackingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
