import 'dart:convert';

import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/logger.dart';

Future<HotKey> getHotkeyFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  var savedHotkey = prefs.getString("hotkey");
  if (savedHotkey == null) {
    final defaultHotkey = {
      'modifiers': [KeyModifier.meta.stringValue],
      'keyCode': KeyCode.space.stringValue
    };
    await prefs.setString('hotkey', jsonEncode(defaultHotkey));
  }
  savedHotkey = prefs.getString('hotkey');
  print(savedHotkey);
  final json = jsonDecode(savedHotkey!);
  final savedModifiers = List<String>.from(json["modifiers"]);
  final savedKeyCode = json["keyCode"];
  final modifiers =
      savedModifiers.map((e) => KeyModifierParser.parse(e)).toList();
  final keyCode = KeyCodeParser.parse(savedKeyCode);
  logger.i('$modifiers, $keyCode');
  return HotKey(keyCode, modifiers: modifiers);
}
