import 'package:flutter/material.dart';

class ButtonAnimationStyle {
  static const Duration duration = Duration(milliseconds: 50); //듀레이션 속도
  static const Curve colorCurve = Curves.easeOut; // ← 색상 변화 전용 커브
  static const BorderSide border = BorderSide(
    color: Color(0xFF252525),
    width: 2,
  ); //버튼 테두리의 색상과 두께

  static const double borderRadius = 30; //R값
  static const Color pressedColor = Color(0xFF333333); //누른상태의 버튼 색상
  // 버튼 눌림 효과용 크기 변화 비율
  static const double scaleX = 1.1; // 가로
  static const double scaleY = 1.2; // 세로
  // 애니메이션 커브 및 지속 시간
  static const Duration scaleDuration = Duration(milliseconds: 100);
  static const Curve scaleCurve = Curves.easeOutCirc;
  static const Curve reverseCurve = Curves.easeIn;
}
