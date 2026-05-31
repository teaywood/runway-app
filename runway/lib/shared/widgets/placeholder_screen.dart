// lib/shared/widgets/placeholder_screen.dart
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final String   title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color:      AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.secondary),
            const SizedBox(height: 20),
            Text(
              '$title Coming Soon',
              style: const TextStyle(
                color:      AppColors.textSecondary,
                fontSize:   18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
