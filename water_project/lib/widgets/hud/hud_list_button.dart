import 'package:flutter/material.dart';
import '../common/buttons/base_icon_button.dart';

class HudListButton extends StatelessWidget {
  const HudListButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      width: 50,
      height: 42,
      onPressed: () {
        // 버튼 동작 정의
      },
      child: Image.asset(
        'lib/icon/list.png',
        width: 26,
        height: 26,
        color: const Color(0xFF9AA0A7), // 인스턴스에서 색상 조절
        fit: BoxFit.contain,
      ),
    );
  }
}
