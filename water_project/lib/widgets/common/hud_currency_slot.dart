import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HudCurrencySlot extends StatelessWidget {
  final String imageAssetPath; // 예: 'lib/icon/money.png'
  final int amount;
  final double height;
  final double iconSize;
  final double fontSize;
  final EdgeInsets padding;

  const HudCurrencySlot({
    super.key,
    required this.imageAssetPath,
    required this.amount,
    this.height = 42,
    this.iconSize = 25,
    this.fontSize = 13,
    this.padding = const EdgeInsets.only(top: 2, left: 8, right: 14, bottom: 2),
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = NumberFormat('#,###').format(amount);

    return Container(
      height: height,
      padding: padding,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2, color: Color(0xFF252525)),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imageAssetPath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 6),
          Text(
            formattedAmount,
            style: TextStyle(
              color: const Color(0xFF9A9FA7),
              fontSize: fontSize,
              fontFamily: 'Paperlogy',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
