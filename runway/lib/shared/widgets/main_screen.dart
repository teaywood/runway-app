// lib/shared/widgets/main_screen.dart
import 'package:flutter/material.dart';
import '../../screen/run_screen/home/home_screen.dart';
import '../../screen/my_room/my_room_screen.dart';
import 'placeholder_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(label: '홈',    icon: Icons.home_rounded,         activeIcon: Icons.home_rounded),
    _TabItem(label: '마이룸', icon: Icons.person_outline,       activeIcon: Icons.person_rounded),
    _TabItem(label: '소셜',  icon: Icons.groups_outlined,      activeIcon: Icons.groups_rounded),
    _TabItem(label: '챌린지', icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded),
  ];

  static final List<Widget> _screens = [
    const HomeScreen(),
    const MyRoomScreen(),
    const PlaceholderScreen(title: '소셜',   icon: Icons.groups_rounded),
    const PlaceholderScreen(title: '챌린지', icon: Icons.emoji_events_rounded),
  ];

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color(0xFFA0A0A0),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

/// 탭 메타데이터 전용 불변 데이터 클래스
class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _TabItem({required this.label, required this.icon, required this.activeIcon});
}
