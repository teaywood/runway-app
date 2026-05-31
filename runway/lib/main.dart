// lib/main.dart
import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'shared/widgets/main_screen.dart';

void main() {
  runApp(const RunWayApp());
}

class RunWayApp extends StatelessWidget {
  const RunWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUN-WAY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainScreen(),
    );
  }
}
