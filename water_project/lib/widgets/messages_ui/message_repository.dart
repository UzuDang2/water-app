import 'dart:convert'; // JSON 문자열을 Map으로 바꾸기 위해 필요
import 'package:flutter/services.dart'; // 로컬 파일 불러오기 위해 필요

/// ✅ 메시지를 로드하고 그룹별로 접근할 수 있도록 관리하는 클래스입니다.
class MessageRepository {
  // ✅ JSON으로부터 파싱한 메시지들을 저장하는 맵입니다.
  // 예: { "tips": [ "문구1", "문구2" ], "lowWater": [ ... ] }
  Map<String, List<String>> _messages = {};

  /// ✅ JSON 파일에서 메시지를 불러와 _messages에 저장합니다.
  /// 앱 시작 시 한 번만 호출되면 됩니다.
  Future<void> loadMessages() async {
    // ✅ 로컬에 있는 JSON 파일을 문자열로 읽어옵니다.
    final jsonStr = await rootBundle.loadString(
      'assets/messages_ui/tips_ko.json',
    );

    // ✅ 문자열을 Map으로 디코딩하고, 각 값을 List<String>으로 변환해 저장합니다.
    _messages = Map<String, List<String>>.from(
      (json.decode(jsonStr) as Map).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ),
    );
  }

  /// ✅ 특정 그룹의 메시지 리스트를 가져옵니다.
  /// 그룹 키가 없을 경우 빈 리스트를 반환합니다.
  List<String> getGroupMessages(String group) {
    return _messages[group] ?? [];
  }
}
