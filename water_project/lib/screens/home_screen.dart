import 'package:flutter/material.dart';
import '../widgets/hud/hud_calendar.dart';
import '../widgets/hud/hud_top.dart'; // 새로 만든 hud_top.dart
import '../widgets/hud/hud_message.dart'; // 메시지 출력 ui

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double currentHydrationLevel = 0.1; // ✅ 테스트용 고정 수분량 (10%)
    return Scaffold(
      body: Column(
        children: const [
          SizedBox(height: 65), // ⬅ 여백 추가
          HudTop(), // 탑 UI
          SizedBox(height: 13), //HudTop과 Calender 사이 간격
          SizedBox(height: 66, child: HudCalendar()), //캘린더 고정높이
          SizedBox(height: 73), // 캘린더와 메시지의 사이 간격
          HudMessage(),
        ],
      ),
    );
  }
}
