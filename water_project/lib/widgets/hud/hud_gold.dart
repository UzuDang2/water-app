import 'package:flutter/material.dart';
import '../common/hud_currency_slot.dart'; // 경로 수정
import '../user/user_local_storage.dart';

class HudGold extends StatefulWidget {
  const HudGold({super.key});

  @override
  State<HudGold> createState() => _HudGoldState();
}

class _HudGoldState extends State<HudGold> {
  int _gold = 0;

  @override
  void initState() {
    super.initState();
    _loadGold();
  }

  Future<void> _loadGold() async {
    final gold = await UserLocalStorage.getGold() ?? 0;
    setState(() {
      _gold = gold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HudCurrencySlot(imageAssetPath: 'lib/icon/money.png', amount: _gold);
  }
}
