import 'package:flutter/material.dart';

/// ✅ 메시지 그룹을 조건에 따라 결정하는 클래스입니다.
/// 조건 우선순위: 사용자 강제 설정 > 시간 조건 > 수분 조건
class MessageGroupSelector {
  final double hydrationLevel;
  final DateTime now;
  final String? userOverrideGroup; // 아직은 null, 추후 개발

  MessageGroupSelector({
    required this.hydrationLevel,
    DateTime? now,
    this.userOverrideGroup,
  }) : now = now ?? DateTime.now(); // 테스트를 위한 now 주입 가능

  /// ✅ 조건에 따라 출력할 메시지 그룹 이름을 반환합니다.
  String selectGroup() {
    // 1. 유저가 강제로 설정한 그룹이 있다면 그 그룹 사용
    if (userOverrideGroup != null) {
      return userOverrideGroup!;
    }

    // 2. 시간 조건 우선 적용
    final hour = now.hour;
    final minute = now.minute;
    final totalMinutes = hour * 60 + minute;

    if (_inRange(totalMinutes, 360, 540)) return 'morning'; // 06:00~09:00
    if (_inRange(totalMinutes, 660, 780)) return 'lunch'; // 11:00~13:00
    if (_inRange(totalMinutes, 900, 1020)) return 'afternoon'; // 15:00~17:00

    // 3. 수분량 조건
    if (hydrationLevel <= 0.3) return 'dehydrated';
    return 'tips';
  }

  /// ✅ 주어진 분 단위 시간값이 범위 안에 있는지 체크합니다.
  bool _inRange(int now, int start, int end) {
    return now >= start && now <= end;
  }
}
