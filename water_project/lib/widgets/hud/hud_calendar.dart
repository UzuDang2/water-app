// ✅ HudCalendar 위젯: 정돈된 구조와 초심자용 주석 포함

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../user/user_local_storage.dart';
import 'dart:async';

// ✅ 날짜 비교를 위한 확장 함수
extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // ✅ 'yyyy-MM-dd' 형식의 키 생성
  String toKey() => DateFormat('yyyy-MM-dd').format(this);
}

class HudCalendar extends StatefulWidget {
  const HudCalendar({super.key});

  @override
  State<HudCalendar> createState() => _HudCalendarState();
}

class _HudCalendarState extends State<HudCalendar>
    with TickerProviderStateMixin {
  // ✅ UI 관련 상수
  static const double _dateItemWidth = 37.0;
  static const double _dateItemPadding = 11.0;
  static const double _monthLabelWidth = 42.0;
  static const double _dayCircleSize = 28.0;
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 700);
  static const Curve _scrollAnimationCurve = Curves.easeOutBack;
  static const Duration _scrollIdleDelay = Duration(seconds: 3);
  static const Duration _opacityAnimationDuration = Duration(milliseconds: 600);
  static const Duration _bounceAnimationDuration = Duration(milliseconds: 900);
  static const Duration _bounceDownDuration = Duration(milliseconds: 250);
  static const Duration _bounceUpDuration = Duration(milliseconds: 650);

  // ✅ 스크롤 관련 변수
  late final ScrollController _scrollController;
  Timer? _scrollIdleTimer;

  // ✅ 애니메이션 관련 변수
  late final AnimationController _opacityAnimationController;
  late final Animation<double> _opacityAnimation;
  late final AnimationController _bounceAnimationController;
  late final Animation<double> _bounceAnimation;
  late final Animation<Color?> _colorAnimation;
  bool _isAnimating = false; // 애니메이션 진행 상태

  // ✅ 날짜 데이터
  late List<DateTime> _dateList;
  Set<String> _attendedDateKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // ✅ 깜빡임 애니메이션 설정
    _opacityAnimationController = AnimationController(
      vsync: this,
      duration: _opacityAnimationDuration,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _opacityAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // ✅ 바운스 애니메이션 설정
    _bounceAnimationController = AnimationController(
      vsync: this,
      duration: _bounceAnimationDuration,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.85), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_bounceAnimationController);
    _colorAnimation = ColorTween(begin: Colors.grey, end: Colors.blue).animate(
      CurvedAnimation(
        parent: _bounceAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _dateList = _generateDateList();
    _loadAttendance();

    // ✅ 위젯 빌드 후 약간의 딜레이 후 오늘 날짜로 스크롤 이동 및 타이머 시작
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToToday(smooth: false);
      _startScrollIdleTimer();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _opacityAnimationController.dispose();
    _bounceAnimationController.dispose();
    _scrollIdleTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleAttendance(DateTime date) async {
    _opacityAnimationController.stop();
    setState(() => _isAnimating = true);
    await _bounceAnimationController.animateTo(
      0.33,
      duration: _bounceDownDuration,
      curve: Curves.easeOut,
    );
    await UserLocalStorage.addAttendanceDate(date);
    await UserLocalStorage.incrementAttendanceCount();
    await UserLocalStorage.incrementGold();
    setState(() => _attendedDateKeys.add(date.toKey()));
    await _bounceAnimationController.animateTo(
      1.0,
      duration: _bounceUpDuration,
      curve: Curves.linear,
    );
    setState(() => _isAnimating = false);
    // ✅ 수정 후 (문제 해결)
    await Future.delayed(const Duration(milliseconds: 100)); // 애니메이션 반영 대기
    if (mounted) {
      _startScrollIdleTimer(); // ⬅️ 이렇게 바꾸시면, 출석 후에도 유저가 스크롤할 수 있고, 3초 후에 자동으로 이동됩니다
    }
  }

  Future<void> _loadAttendance() async {
    Set<String> attendedKeys = {};
    for (final date in _dateList) {
      if (await UserLocalStorage.isDateAttended(date)) {
        attendedKeys.add(date.toKey());
      }
    }
    setState(() => _attendedDateKeys = attendedKeys);
  }

  List<DateTime> _generateDateList() {
    final today = DateTime.now();
    final firstDayOfLastMonth = DateTime(today.year, today.month - 1, 1);
    final lastDayOfThisWeek = today.add(
      Duration(days: 6 - (today.weekday % 7)),
    );
    final dateList = <DateTime>[];
    DateTime currentDate = firstDayOfLastMonth;
    while (!currentDate.isAfter(lastDayOfThisWeek)) {
      dateList.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return dateList;
  }

  void _scrollToToday({bool smooth = false}) {
    final today = DateTime.now();
    final todayIndex = _dateList.indexWhere((date) => date.isSameDate(today));
    if (todayIndex == -1) return;

    final extraLabelCount = _countMonthLabelsBefore(todayIndex);
    final itemTotalWidth = _dateItemWidth + (_dateItemPadding * 2);
    final offset =
        ((todayIndex + 0.5) * itemTotalWidth +
            extraLabelCount * _monthLabelWidth) -
        (MediaQuery.of(context).size.width / 2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        final targetOffset = offset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        if (smooth) {
          _scrollController.animateTo(
            targetOffset,
            duration: _scrollAnimationDuration,
            curve: _scrollAnimationCurve,
          );
        } else {
          _scrollController.jumpTo(targetOffset);
        }
      }
    });
  }

  void _startScrollIdleTimer() {
    _scrollIdleTimer?.cancel();
    _scrollIdleTimer = Timer(_scrollIdleDelay, () {
      if (mounted && _scrollController.hasClients) {
        setState(() {
          _scrollToToday(smooth: true); // ✅ setState로 래핑하여 리렌더 유도
        });
      }
    });
  }

  int _countMonthLabelsBefore(int targetIndex) {
    int count = 0;
    for (int i = 1; i <= targetIndex; i++) {
      if (_dateList[i].month != _dateList[i - 1].month) {
        count++;
      }
    }
    return count;
  }

  Widget _buildDateItem(
    DateTime date,
    bool isToday,
    bool isAttended,
    bool isMonthLabel,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMonthLabel)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${date.month}월',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _dateItemPadding),
          child: Column(
            children: [
              Container(
                width: _dateItemWidth,
                height: 66.0,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                decoration:
                    isToday
                        ? ShapeDecoration(
                          color: const Color(0xFF252525),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.83),
                          ),
                        )
                        : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.E('ko').format(date),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: isToday ? Colors.white : const Color(0xff464646),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    _buildDayCircle(date, isToday, isAttended),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCircle(DateTime date, bool isToday, bool isAttended) {
    if (isToday && !isAttended) {
      return FadeTransition(
        opacity:
            _isAnimating
                ? const AlwaysStoppedAnimation(1.0)
                : _opacityAnimation,
        child: GestureDetector(
          onTap: () => _handleAttendance(date),
          child: AnimatedBuilder(
            animation: _bounceAnimationController,
            builder:
                (context, child) => Transform.scale(
                  scale: _bounceAnimation.value,
                  child: child,
                ),
            child: _buildCircle(
              date.day.toString(),
              _dayCircleSize,
              _colorAnimation.value ?? Colors.grey,
            ),
          ),
        ),
      );
    } else {
      final circleColor = isAttended ? Colors.blue : Colors.transparent;
      final textColor = isToday ? Colors.white : const Color(0xff464646);
      return _buildCircle(
        date.day.toString(),
        _dayCircleSize,
        circleColor,
        textColor: textColor,
      );
    }
  }

  Widget _buildCircle(
    String text,
    double size,
    Color backgroundColor, {
    Color? textColor,
  }) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo is ScrollUpdateNotification ||
        scrollInfo is UserScrollNotification) {
      _scrollIdleTimer?.cancel();
    }
    if (scrollInfo is ScrollEndNotification) {
      _startScrollIdleTimer();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66.0,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _dateList.length,
          itemBuilder: (context, index) {
            final date = _dateList[index];
            final isToday = date.isSameDate(DateTime.now());
            final isAttended = _attendedDateKeys.contains(date.toKey());
            final isMonthLabel =
                index > 0 && date.month != _dateList[index - 1].month;
            return _buildDateItem(date, isToday, isAttended, isMonthLabel);
          },
        ),
      ),
    );
  }
}
