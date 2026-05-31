// lib/screen/running/widgets/run_app_bar.dart
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

/// 러닝 계열 화면 공통 AppBar (RUN-WAY 로고 + 메뉴)
class RunAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RunAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'RUN-WAY',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}
