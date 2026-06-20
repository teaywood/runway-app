// lib/screen/run_screen/home/widgets/course_selection.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../countdown/countdown_screen.dart';
import '../../running/course_running_screen.dart';

/// ── 코스 데이터 모델 (데모용 하드코딩) ──────────────────────
class _CourseData {
  final String title;
  final String subtitle;
  final String imagePath;       // assets 경로 (플레이스홀더)
  final String distance;
  final String estimatedTime;

  const _CourseData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.distance,
    required this.estimatedTime,
  });
}

/// ── 코스 선택 카루셀 화면 ──────────────────────────────────
class CourseSelectionScreen extends StatefulWidget {
  final double targetDistance;
  final String courseType;

  const CourseSelectionScreen({
    super.key,
    required this.targetDistance,
    required this.courseType,
  });

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  late final PageController _pageController;
  double _currentPage = 1.0; // 가운데(인덱스 1)에서 시작

  // ── 데모용 3개 코스 ────────────────────────────────────────
  static const _courses = [
    _CourseData(
      title:         '코스 A',
      subtitle:      '시티런 코스',
      imagePath:     'assets/images/course_1.png',
      distance:      '2.0 km',
      estimatedTime: '약 14분',
    ),
    _CourseData(
      title:         '코스 B',
      subtitle:      '한강 코스',
      imagePath:     'assets/images/course_2.png',
      distance:      '2.1 km',
      estimatedTime: '약 15분',
    ),
    _CourseData(
      title:         '코스 C',
      subtitle:      '순환 코스',
      imagePath:     'assets/images/course_3.png',
      distance:      '2.4 km',
      estimatedTime: '약 18분',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.72, // 양 옆 카드 살짝 보이게
      initialPage: 1,
    )..addListener(_onPageScroll);
  }

  void _onPageScroll() {
    setState(() => _currentPage = _pageController.page ?? 1.0);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  /// 선택 완료 → 카운트다운 → 코스 러닝
  void _onCourseSelected(int index) {
    final course = _courses[index];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CountdownScreen(
          targetScreen: CourseRunningScreen(
            targetDistance: widget.targetDistance,
            courseType:     widget.courseType,
            // safeMode 제거됨 — 백엔드 기본 안심 적용
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI 추천 코스',
          style: TextStyle(
            color:      AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize:   20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 설정 요약 뱃지 ──────────────────────────────
            _ConditionBadge(
              distance:   widget.targetDistance,
              courseType:  widget.courseType,
            ),

            const SizedBox(height: 8),

            // ── 안내 문구 ───────────────────────────────────
            Text(
              '좌우로 스와이프하여 코스를 선택하세요',
              style: TextStyle(
                color:    AppColors.textSecondary,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // ── 카루셀 영역 ─────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount:  _courses.length,
                itemBuilder: (context, index) {
                  return _CourseCard(
                    course:      _courses[index],
                    currentPage: _currentPage,
                    index:       index,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── 페이지 인디케이터 ───────────────────────────
            _PageIndicator(
              count:       _courses.length,
              currentPage: _currentPage,
            ),

            const SizedBox(height: 20),

            // ── 선택 버튼 ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _onCourseSelected(_currentPage.round().clamp(0, 2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '이 코스로 달리기',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  서브 위젯들
// ═══════════════════════════════════════════════════════════════

/// ── 설정 요약 뱃지 ─────────────────────────────────────────
class _ConditionBadge extends StatelessWidget {
  final double distance;
  final String courseType;
  const _ConditionBadge({required this.distance, required this.courseType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:        AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tune_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            '${distance.toStringAsFixed(1)} km  ·  $courseType  ·  안심 기본 적용',
            style: const TextStyle(
              color:      AppColors.primary,
              fontSize:   13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── 카루셀 카드 (스케일 + 오파시티 트랜지션) ────────────────
class _CourseCard extends StatelessWidget {
  final _CourseData course;
  final double      currentPage;
  final int         index;

  const _CourseCard({
    required this.course,
    required this.currentPage,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // ── 중앙과의 거리 계산 ─────────────────────────────────
    final double diff = (currentPage - index).abs().clamp(0.0, 1.0);

    // 중앙: scale 1.0, opacity 1.0
    // 양옆: scale 0.85, opacity 0.45
    final double scale   = 1.0 - (diff * 0.15);
    final double opacity = 1.0 - (diff * 0.55);

    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: scale, end: scale),
      duration: const Duration(milliseconds: 150),
      builder: (context, animScale, child) {
        return Transform.scale(
          scale: animScale,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: diff < 0.5
                ? AppColors.primary.withOpacity(0.60)
                : AppColors.cardBorder,
            width: diff < 0.5 ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (diff < 0.5)
              BoxShadow(
                color:      AppColors.primary.withOpacity(0.18),
                blurRadius: 24,
                offset:     const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 코스 이미지 (플레이스홀더) ──────────────────
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                child: Container(
                  color: AppColors.background,
                  child: Image.asset(
                    course.imagePath,
                    fit: BoxFit.cover,
                    // 이미지 없을 때 대비 — 지도 아이콘 플레이스홀더
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_rounded,
                              size: 64,
                              color: AppColors.primary.withOpacity(0.35)),
                          const SizedBox(height: 8),
                          Text(
                            course.title,
                            style: TextStyle(
                              color:    AppColors.primary.withOpacity(0.5),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 코스 정보 ──────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        color:      AppColors.textPrimary,
                        fontSize:   20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.subtitle,
                      style: TextStyle(
                        color:    AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    // ── 거리 · 시간 칩 ──────────────────────
                    Row(
                      children: [
                        _InfoChip(
                          icon:  Icons.straighten_rounded,
                          label: course.distance,
                        ),
                        const SizedBox(width: 10),
                        _InfoChip(
                          icon:  Icons.timer_outlined,
                          label: course.estimatedTime,
                        ),
                      ],
                    ),
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

/// ── 정보 칩 (거리/시간 표시용) ──────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color:      AppColors.primary,
              fontSize:   12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ── 페이지 인디케이터 (도트) ────────────────────────────────
class _PageIndicator extends StatelessWidget {
  final int    count;
  final double currentPage;
  const _PageIndicator({required this.count, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final double diff = (currentPage - i).abs().clamp(0.0, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin:  const EdgeInsets.symmetric(horizontal: 4),
          width:   diff < 0.5 ? 24 : 8,
          height:  8,
          decoration: BoxDecoration(
            color: diff < 0.5
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
