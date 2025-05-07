import 'package:flutter/material.dart';
import 'hud_user.dart';
import 'hud_gold.dart';
import 'hud_list_button.dart';

class HudTop extends StatelessWidget {
  const HudTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46, //원하는 높이
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          HudUser(), // 왼쪽 정렬
          Spacer(), // 오른쪽으로 밀기
          HudGold(), // 오른쪽 정렬
          SizedBox(width: 8), //골드와 버튼사이의 간격
          HudListButton(), // ← 리스트 버튼 추가
        ],
      ),
    );
  }
}
