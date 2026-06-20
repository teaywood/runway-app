// lib/screen/run_screen/running/course_running_screen.dart
import 'package:flutter/material.dart';
import '../result/result_screen.dart';
import 'logic/run_session_mixin.dart';
import 'widgets/run_app_bar.dart';
import 'widgets/run_map_area.dart';
import 'widgets/run_info_row.dart';
import 'widgets/run_control_bar.dart';
import 'widgets/course_progress_section.dart';

/// ═══════════════════════════════════════════════════════════
/// 🗺️ COURSE RUNNING SCREEN — 코스 달리기 (목표 거리 + 진행률)
/// ═══════════════════════════════════════════════════════════
class CourseRunningScreen extends StatefulWidget {
  final double targetDistance;
  final String courseType;
  final String courseImagePath;

  const CourseRunningScreen({
    super.key,
    required this.targetDistance,
    required this.courseType,
    this.courseImagePath = 'assets/images/course_2.png',
  });

  @override
  State<CourseRunningScreen> createState() => _CourseRunningScreenState();
}

class _CourseRunningScreenState extends State<CourseRunningScreen>
    with RunSessionMixin {
  @override
  void initState() {
    super.initState();
    startSession();
  }

  void _onStop() {
    // ── 종료 시점의 진행률을 캡처 ──
    final finalProgress =
        (distance / widget.targetDistance).clamp(0.0, 1.0);

    stopSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          time: formattedTime,
          distance: formattedDistance,
          pace: formattedPace,
          calories: estimatedCalories,
          courseImagePath: widget.courseImagePath,
          progress: finalProgress, // ← 추가
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 진행률 계산 (Course 고유)
    final progressRate =
        (distance / widget.targetDistance).clamp(0.0, 1.0);
    final remainingDistance =
        (widget.targetDistance - distance).clamp(0.0, widget.targetDistance);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const RunAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 지도 (코스 이미지 + AI 경로선 칩)
            Expanded(
              child: RunMapArea(
                courseImagePath: widget.courseImagePath,
              ),
            ),
            // 진행률 바 (Course 고유)
            CourseProgressSection(
              progressRate: progressRate,
              remainingDistance: remainingDistance,
            ),
            const SizedBox(height: 16),
            // 통계 + 남은거리 카드
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  RunInfoRow(
                    distance: formattedDistance,
                    pace: formattedPace,
                    time: formattedTime,
                  ),
                  const SizedBox(height: 16),
                  RemainingDistanceCard(
                    remainingDistance: remainingDistance,
                  ),
                ],
              ),
            ),
            // 컨트롤 바 (공통)
            RunControlBar(
              isPaused: isPaused,
              onPauseToggle: togglePause,
              onStop: _onStop,
            ),
          ],
        ),
      ),
    );
  }
}
