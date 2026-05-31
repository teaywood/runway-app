// lib/screen/running/running_screen.dart
import 'package:flutter/material.dart';
import '../result/result_screen.dart';
import 'logic/run_session_mixin.dart';
import 'widgets/run_app_bar.dart';
import 'widgets/run_map_area.dart';
import 'widgets/run_info_row.dart';
import 'widgets/run_control_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// 🏃 RUNNING SCREEN — 자유 달리기 (목표 없음)
/// ═══════════════════════════════════════════════════════════
class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen>
    with RunSessionMixin<RunningScreen> {
  @override
  void initState() {
    super.initState();
    startSession();
  }

  void _onStop() {
    stopSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          time: formattedTime,
          distance: formattedDistance,
          pace: formattedPace,
          calories: estimatedCalories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const RunAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: RunMapArea()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: RunInfoRow(
                distance: formattedDistance,
                pace: formattedPace,
                time: formattedTime,
              ),
            ),
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
