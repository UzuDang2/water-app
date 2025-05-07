import 'package:flutter/material.dart';
import '../user/user_local_storage.dart';

class HudUser extends StatefulWidget {
  const HudUser({super.key});

  @override
  State<HudUser> createState() => _HudUserState();
}

class _HudUserState extends State<HudUser> {
  String _nickname = '...';
  int _level = 0;
  int _exp = 0;

  // 테스트용 주석처리 가능한 임시 닉네임
  final String _testNickname = '우주댕댕이';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final nickname = await UserLocalStorage.getNickname() ?? _testNickname;
    final level = await UserLocalStorage.getLevel() ?? 0;
    final exp = await UserLocalStorage.getExp() ?? 0;

    setState(() {
      _nickname = nickname;
      _level = level;
      _exp = exp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _nickname,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AA0A7),
              fontFamily: 'Paperlogy',
            ),
          ),
          const SizedBox(width: 7),
          Transform.translate(
            offset: const Offset(0, -1.5), // y축으로 살짝 위로
            child: Text(
              'LV $_level',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2691CE),
                fontFamily: 'Paperlogy',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
