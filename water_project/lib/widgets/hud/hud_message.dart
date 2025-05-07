// ✅ 메시지 우선순위 기반으로 조건을 평가하고 메시지를 출력하는 HudMessage 위젯

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; //텍스트 사이즈 조절
import '../messages_ui/message_repository.dart';
import 'package:intl/intl.dart'; // 시간 비교를 위해 필요

class HudMessage extends StatefulWidget {
  const HudMessage({super.key});

  @override
  State<HudMessage> createState() => _HudMessageState();
}

class _HudMessageState extends State<HudMessage> {
  final _repository = MessageRepository();
  String _currentMessage = '...로딩 중';

  // ✅ 수분량은 현재 테스트용 고정값 (0.1 = 10%)
  double get _hydrationLevel => 0.1;

  // ✅ 조건 우선순위 정의 (앞에 있을수록 우선 적용)
  final List<String> _priorityOrder = [
    'userSetting', // 향후 유저 세팅이 추가될 경우 최우선
    'timeOfDay', // 시간대 조건
    'hydrationLevel', // 수분 상태 조건
  ];

  // ✅ 각 조건 키와 해당 조건 판단 함수 매핑
  late final Map<String, String? Function()> _resolvers;

  @override
  void initState() {
    super.initState();
    _resolvers = {
      'userSetting': _resolveUserSettingGroup, // ⚠ 향후 구현 필요
      'timeOfDay': _resolveTimeOfDayGroup,
      'hydrationLevel': _resolveHydrationGroup,
    };
    _loadAndScheduleMessage();
  }

  // ✅ 메시지 불러오고 30초마다 새로 갱신
  void _loadAndScheduleMessage() async {
    await _repository.loadMessages();
    _updateMessage();
    Timer.periodic(const Duration(seconds: 30), (_) => _updateMessage());
  }

  // ✅ 우선순위에 따라 가장 먼저 매칭되는 그룹을 선택하고 메시지 업데이트
  void _updateMessage() {
    String? selectedGroup;
    for (final key in _priorityOrder) {
      final group = _resolvers[key]?.call();
      if (group != null) {
        selectedGroup = group;
        break;
      }
    }

    final messages = _repository.getGroupMessages(selectedGroup ?? 'tips');
    if (messages.isNotEmpty) {
      final selected = (messages..shuffle()).first;
      setState(() => _currentMessage = selected);
    }
  }

  // ✅ (미구현) 유저 설정 기반 그룹 판단
  String? _resolveUserSettingGroup() {
    return null; // 현재는 조건 없음
  }

  // ✅ 시간대에 따라 메시지 그룹을 반환
  String? _resolveTimeOfDayGroup() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 9) {
      return 'morning';
    } else if (hour >= 11 && hour < 13) {
      return 'lunch';
    } else if (hour >= 15 && hour < 17) {
      return 'afternoon';
    }
    return null;
  }

  // ✅ 수분량에 따라 그룹 판단
  String? _resolveHydrationGroup() {
    return _hydrationLevel <= 0.3 ? 'dehydrated' : 'tips';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool shouldShrink = constraints.maxWidth > 340;

        return SizedBox(
          width: 340, // ✅ 고정 너비로 판단 (중앙 정렬된 상태 기준)
          child: AutoSizeText(
            _currentMessage,
            maxLines: 1, // ✅ 1줄까지 허용
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22, // ✅ 최대 폰트 사이즈
              color: Color(0xFFEAEAEA),
              fontFamily: 'Paperlogy',
              fontWeight: FontWeight.w500,
              height: 1.4, // ✅ 줄 간격 조절 (22px 기준 약 30.8px)
            ),
            minFontSize: shouldShrink ? 18 : 22, // ✅ 340 넘을 때만 축소 허용
            stepGranularity: 1, // ✅ 줄어드는 단위
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
