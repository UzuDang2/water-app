// base_icon_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_project/widgets/common/styles/button_animation_style.dart';

class BaseIconButton extends StatefulWidget {
  final double width;
  final double height;
  final Widget child; // 아이콘 대신 위젯을 직접 받음
  final VoidCallback onPressed;

  const BaseIconButton({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    required this.onPressed,
  });

  @override
  State<BaseIconButton> createState() => _BaseIconButtonState();
}

class _BaseIconButtonState extends State<BaseIconButton>
    with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러: 버튼이 눌렸을 때 커졌다 작아지는 애니메이션을 제어함
  late final AnimationController _scaleController;

  // 애니메이션 값: 버튼의 스케일(크기)를 제어하는 Tween
  late final Animation<double> _scaleAnimation;

  // 버튼이 눌렸는지를 추적하는 상태값
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _scaleController = AnimationController(
      vsync: this,
      duration: ButtonAnimationStyle.scaleDuration, // 버튼이 커지는 시간
      reverseDuration: ButtonAnimationStyle.scaleDuration, // 원래 크기로 돌아가는 시간
    );

    // Tween을 통해 1.0(기본 크기) → 1.2(확대 크기)로 스케일 애니메이션 설정
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end:
          ButtonAnimationStyle
              .scaleY, // ButtonAnimationStyle에서 설정한 세로 크기 비율 (기본: 1.2)
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: ButtonAnimationStyle.scaleCurve, // 눌릴 때 커브 곡선
        reverseCurve: ButtonAnimationStyle.reverseCurve, // 되돌아갈 때 커브 곡선
      ),
    );
  }

  @override
  void dispose() {
    // 컨트롤러는 반드시 dispose 해줘야 메모리 누수 방지됨
    _scaleController.dispose();
    super.dispose();
  }

  // 버튼을 누르기 시작했을 때 실행됨
  void _handleTapDown(_) {
    HapticFeedback.lightImpact(); // 가벼운 진동 효과
    _scaleController.forward(); // 버튼 확대 시작
    setState(() => _isPressed = true); // 상태 업데이트: 눌림 색상 적용
  }

  // 버튼에서 손을 뗐을 때 실행됨
  void _handleTapUp(_) {
    widget.onPressed(); // 전달받은 콜백 실행
    _scaleController.reverse(); // 버튼 축소(원래 크기) 시작
    setState(() => _isPressed = false); // 색상 원상복귀
  }

  // 누르다 말고 취소됐을 때 실행됨 (예: 손가락이 벗어났을 때)
  void _handleTapCancel() {
    _scaleController.reverse(); // 원래 크기로 돌아감
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          // Transform.scale로 버튼을 확대/축소하는 효과 적용
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedContainer(
          duration: ButtonAnimationStyle.duration, // 색상 변화 애니메이션 시간
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: ButtonAnimationStyle.border.color,
              width: ButtonAnimationStyle.border.width,
            ),
            borderRadius: BorderRadius.circular(
              ButtonAnimationStyle.borderRadius,
            ),
            color:
                _isPressed
                    ? ButtonAnimationStyle
                        .pressedColor // 눌렀을 때 색상
                    : Colors.transparent, // 평상시 색상 (투명)
          ),
          child: Center(child: widget.child), // 버튼 안에 표시될 아이콘 or 위젯
        ),
      ),
    );
  }
}
