import 'dart:async';

import 'package:flutter/services.dart';

class HotkeyShortcuts {
  static const MethodChannel _channel = const MethodChannel('hotkey_shortcuts');

  static final Map<String, List<void Function()>> hotkeyMap = {};

  static Future<String> get platformVersion async {
    _channel.setMethodCallHandler(_onHotkey);
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future register(String hotkey, void Function() callback) {
    var list = hotkeyMap[hotkey];
    if (list == null) {
      list = [callback];
      _channel.invokeMethod("registerHotkey", [hotkey]);
    } else {
      list.add(callback);
    }
    hotkeyMap[hotkey] = list;
    return null;
  }

  static Future _onHotkey(MethodCall call) {
    if (call.method != 'onHotkey') {
      return null;
    }
    var hotkey = call.arguments[0];
    var list = hotkeyMap[hotkey];
    if (list == null) {
      return null;
    }
    list.forEach((element) {
      element();
    });
    return null;
  }
}
