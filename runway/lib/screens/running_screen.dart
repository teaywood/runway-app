import 'package:flutter/material.dart';
import 'result_screen.dart';
import 'dart:async';

// ═══════════════════════════════════════════════════════════
// 🏃 RUNNING SCREEN
// 사용자가 달리기를 시작했을 때 보이는 메인 러닝 화면
// 레이아웃 구조: AppBar → 지도(Expanded) → 정보창 → 버튼
// ═══════════════════════════════════════════════════════════
class RunningScreen extends StatefulWidget {
  const RunningScreen({super.key});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

// ═══════════════════════════════════════════════════════════
// 🏃 RUNNING SCREEN STATE
// ═══════════════════════════════════════════════════════════
class _RunningScreenState extends State<RunningScreen> {
  Timer? _timer;
  int _seconds = 0;
  double _distance = 0.0;

  // 🎨 앱 전체에서 쓰는 포인트 컬러 (라벤더/퍼플)
  static const Color kPurple = Color(0xFF7C6BFF);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        _distance += 0.0028; // 약 2.8m/s 속도
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _calculatePace(int seconds, double distance) {
    if (distance == 0) return "0'00\"";
    double paceMinutes = seconds / 60 / distance;
    int minutes = paceMinutes.floor();
    int secs = ((paceMinutes - minutes) * 60).round();
    return "$minutes'${secs.toString().padLeft(2, '0')}\"";
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─────────────────────────────────────────
      // 🤍 배경: 깔끔한 화이트
      // ─────────────────────────────────────────
      backgroundColor: Colors.white,

      // ═══════════════════════════════════════════
      // 1️⃣ 상단 AppBar
      // ═══════════════════════════════════════════
      appBar: AppBar(
        backgroundColor: Colors.white, // 흰색 배경
        elevation: 0, // 그림자 제거 (깔끔하게)
        centerTitle: true,
        // 좌측: 'RUN-WAY' 텍스트 로고
        title: const Text(
          'RUN-WAY',
          style: TextStyle(
            color: kPurple, // 퍼플 컬러
            fontWeight: FontWeight.bold, // 볼드체
            fontSize: 22,
            letterSpacing: 1.5, // 자간 (로고 느낌)
          ),
        ),

        // 우측: 햄버거 메뉴 (설정) 아이콘
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: kPurple),
            onPressed: () {
              // TODO: 설정 메뉴 열기
            },
          ),
        ],
      ),

      // ═══════════════════════════════════════════
      // 본문 시작 (SafeArea로 노치/홈바 영역 보호)
      // ═══════════════════════════════════════════
      body: SafeArea(
        child: Column(
          children: [
            // ═════════════════════════════════════
            // 2️⃣ 중단: 지도 영역 (Expanded 필수!)
            //    화면 크기 변해도 절대 사라지지 않음
            // ═════════════════════════════════════
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                // Stack: 가짜 지도 위에 아바타 박스를 겹쳐 놓기
                child: Stack(
                  children: [
                    // ─────────────────────────────
                    // 🗺️ 바탕: 가짜 지도 (연한 회색)
                    // ─────────────────────────────
                    Container(
                      // double.infinity = "부모가 허락하는 만큼 꽉 채워!"
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // 연한 회색
                        borderRadius: BorderRadius.circular(20), // 둥근 모서리
                      ),
                      // 가짜 지도임을 알 수 있게 가운데 텍스트 (선택)
                      child: Center(
                        child: Text(
                          '🗺️ MAP AREA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),

                    // ─────────────────────────────
                    // 🏃 좌상단: 달리는 아바타 박스
                    // Positioned: Stack 안에서 위치 지정
                    // ─────────────────────────────
                    Positioned(
                      top: 16, // 위에서 16px 여백
                      left: 16, // 왼쪽에서 16px 여백
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white, // 흰색 박스
                          borderRadius: BorderRadius.circular(12),
                          // 살짝의 그림자로 떠있는 느낌
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          '달리는 아바타',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D3A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ═════════════════════════════════════
            // 러닝 정보창 (거리/페이스/시간)
            // ═════════════════════════════════════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                // spaceEvenly: 세 항목 사이 간격을 균등하게 띄움
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  // 📏 거리
                  _InfoItem(value: _distance.toStringAsFixed(2), unit: 'km', label: '거리'),
                  // ⚡ 페이스
                  _InfoItem(value: _calculatePace(_seconds, _distance), unit: '/km', label: '페이스'),
                  // ⏱️ 시간
                  _InfoItem(value: _formatTime(_seconds), unit: 'time', label: '시간'),
                ],
              ),
            ),

            // ═════════════════════════════════════
            // 4️⃣ 최하단: 조작 버튼부 (일시정지 / 종료)
            // ═════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // ⏸️ 일시정지 버튼 (라벤더)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 일시정지 로직
                      },
                      icon: const Icon(Icons.pause, size: 24),
                      label: const Text(
                        '일시정지',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple, // 라벤더
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // 둥근 모서리
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12), // 버튼 사이 간격
                  // ⏹️ 종료 버튼 (빨간색 계열로 구분)
                  // ⏹️ 종료 버튼 (빨간색 계열로 구분)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ✅ 결과 화면으로 이동 (뒤로가기 불가능하게 교체)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResultScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.stop, size: 24),
                      label: const Text(
                        '종료',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E5E), // 빨강 계열
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📊 _InfoItem: 러닝 정보 한 칸 위젯 (거리/페이스/시간 공통)
// 숫자는 크고 굵게, 단위와 라벨은 작게
// ═══════════════════════════════════════════════════════════
class _InfoItem extends StatelessWidget {
  final String value; // 큰 숫자 (예: '3.14')
  final String unit; // 단위 (예: 'km')
  final String label; // 라벨 (예: '거리')

  const _InfoItem({
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔢 큰 숫자
        Text(
          value,
          style: const TextStyle(
            fontSize: 24, // 요청대로 24
            fontWeight: FontWeight.bold, // 두껍게
            color: Color(0xFF2D2D3A),
          ),
        ),
        const SizedBox(height: 4),
        // 📐 단위 (작게)
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        // 🏷️ 라벨 (제일 작게)
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
