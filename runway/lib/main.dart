import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screens/running_screen.dart';
import 'screens/course_running_screen.dart';
import 'screens/countdown_screen.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F7FF),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlaceholderScreen(title: '마이룸', icon: Icons.person_outline),
    const PlaceholderScreen(title: '소셜', icon: Icons.groups_outlined),
    const PlaceholderScreen(title: '챌린지', icon: Icons.emoji_events_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF7C6BFF),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이룸',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: '소셜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: '챌린지',
        ),
      ],
    ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _runningMode = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'RUN-WAY',
          style: TextStyle(
            color: Color(0xFF7C6BFF),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF7C6BFF)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 150,
                    color: Color(0xFFB8A9FF),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // ✅ 너비를 명시적으로 설정하여 초기 렌더링 시 크기 보장
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40, // 좌우 패딩 20씩 고려
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _runningMode,
                        backgroundColor: const Color(0xFFEDE9FF),
                        thumbColor: Colors.white,
                        children: {
                          0: Container(
                            constraints: BoxConstraints(
                              minWidth: (MediaQuery.of(context).size.width - 44) / 2, // 각 버튼 최소 너비
                              minHeight: 40, // 최소 높이
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '일반 러닝',
                                maxLines: 1,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          1: Container(
                            constraints: BoxConstraints(
                              minWidth: (MediaQuery.of(context).size.width - 44) / 2,
                              minHeight: 40,
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '코스 러닝',
                                maxLines: 1,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() => _runningMode = value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    // ✅ 시작 버튼 (화면 너비의 65%)
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            // _runningMode: 0 = 일반 러닝, 1 = 코스 러닝
                            if (_runningMode == 0) {
                              // 일반 러닝: 바로 카운트다운 → RunningScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CountdownScreen(
                                    targetScreen: RunningScreen(),
                                  ),
                                ),
                              );
                            } else {
                              // 코스 러닝: 팝업 먼저 띄우기
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const CourseConditionDialog(),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C6BFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            '시작',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // ✅ 하단 여백 추가
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF7C6BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: const Color(0xFFB8A9FF)),
            const SizedBox(height: 20),
            Text(
              '$title Coming Soon',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7C6BFF),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 🎯 COURSE CONDITION DIALOG
// 코스 러닝 모드 선택 시 뜨는 조건 입력 팝업
// ═══════════════════════════════════════════════════════════
class CourseConditionDialog extends StatefulWidget {
  const CourseConditionDialog({super.key});

  @override
  State<CourseConditionDialog> createState() => _CourseConditionDialogState();
}

class _CourseConditionDialogState extends State<CourseConditionDialog> {
  static const Color kPurple = Color(0xFF7C6BFF);

  double _targetDistance = 5.0; // 목표 거리 (기본값 5km)
  String _courseType = '편도'; // 코스 형태 (편도/왕복)
  bool _safeMode = false; // 안심 코스 모드 (CCTV/가로등 우선)

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════
            // 제목
            // ═══════════════════════════════════════════
            const Text(
              '맞춤형 코스 설정',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPurple,
              ),
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════
            // 1️⃣ 목표 거리 (Slider)
            // ═══════════════════════════════════════════
            Text(
              '목표 거리: ${_targetDistance.toStringAsFixed(1)} km',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D3A),
              ),
            ),
            Slider(
              value: _targetDistance,
              min: 1.0,
              max: 20.0,
              divisions: 19,
              activeColor: kPurple,
              onChanged: (value) {
                setState(() {
                  _targetDistance = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // ═══════════════════════════════════════════
            // 2️⃣ 코스 형태 (Radio 버튼)
            // ═══════════════════════════════════════════
            const Text(
              '코스 형태',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D3A),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('편도'),
                    value: '편도',
                    groupValue: _courseType,
                    activeColor: kPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _courseType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('왕복'),
                    value: '왕복',
                    groupValue: _courseType,
                    activeColor: kPurple,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _courseType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ═══════════════════════════════════════════
            // 3️⃣ 안심 코스 모드 (Switch)
            // ═══════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '안심 코스 모드\n(CCTV/가로등 우선)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D3A),
                  ),
                ),
                Switch(
                  value: _safeMode,
                  activeColor: kPurple,
                  onChanged: (value) {
                    setState(() {
                      _safeMode = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ═══════════════════════════════════════════
            // 하단 버튼: "코스 탐색 및 시작"
            // ═══════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 팝업 닫기
                  Navigator.pop(context);
                  // 카운트다운 → CourseRunningScreen으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CountdownScreen(
                        targetScreen: CourseRunningScreen(
                          targetDistance: _targetDistance,
                          courseType: _courseType,
                          safeMode: _safeMode,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '코스 탐색 및 시작',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
