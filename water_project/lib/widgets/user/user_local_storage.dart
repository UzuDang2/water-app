import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserLocalStorage {
  static const _keyGold = 'user_gold';
  //static const _keyNickname = 'user_nickname';
  static const _keyAttendanceCount = 'user_attendance_count';
  static const _keyAttendedDates = 'user_attended_dates';

  static const _keyNickname = 'user_nickname';
  static const _keyLevel = 'user_level';
  static const _keyExp = 'user_exp';

  static String _dateToKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 출석 날짜 추가
  static Future<void> addAttendanceDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyAttendedDates) ?? [];
    final key = _dateToKey(date);
    if (!list.contains(key)) {
      list.add(key);
      await prefs.setStringList(_keyAttendedDates, list);
    }
  }

  // 출석했는지 여부 확인
  static Future<bool> isDateAttended(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyAttendedDates) ?? [];
    return list.contains(_dateToKey(date));
  }

  // 출석일 수 증가
  static Future<void> incrementAttendanceCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyAttendanceCount) ?? 0;
    await prefs.setInt(_keyAttendanceCount, count + 1);
  }

  // 골드 증가
  static Future<void> incrementGold() async {
    final prefs = await SharedPreferences.getInstance();
    final gold = prefs.getInt(_keyGold) ?? 0;
    await prefs.setInt(_keyGold, gold + 1);
  }

  // 골드 조회 (기본값: 100)
  static Future<int> getGold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyGold) ?? 100;
  }

  // ✅ 닉네임 저장
  static Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, nickname);
  }

  // ✅ 닉네임 불러오기 (기본값: '우주댕댕이')
  static Future<String> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNickname) ?? '우주댕댕이'; // 테스트용
  }

  // ✅ 레벨 저장
  static Future<void> setLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLevel, level);
  }

  // ✅ 레벨 불러오기 (기본값: 0)
  static Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLevel) ?? 0;
  }

  // ✅ 경험치 저장
  static Future<void> setExp(int exp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyExp, exp);
  }

  // ✅ 경험치 불러오기 (기본값: 0)
  static Future<int> getExp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyExp) ?? 0;
  }
}
