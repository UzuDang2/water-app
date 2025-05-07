import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko');

  const bool isDebug = true;
  if (isDebug) {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e, stack) {
      print('초기화 중 오류: $e');
      print(stack);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // ← 앱 전역 Scaffold 배경색
        // 다른 테마 설정...
        fontFamily: 'Paperlogy', // 위에서 등록한 family 이름
      ),
      home: const HomeScreen(),
    );
  }
}
