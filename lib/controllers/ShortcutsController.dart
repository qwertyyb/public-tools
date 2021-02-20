import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:window_activator/window_activator.dart';

class ShortcutsController {
  // 工厂模式
  factory ShortcutsController() => _getInstance();
  static ShortcutsController get instance => _getInstance();
  static ShortcutsController _instance;
  static ShortcutsController _getInstance() {
    if (_instance == null) {
      _instance = new ShortcutsController._internal();
    }
    return _instance;
  }

  ShortcutsController._internal() {
    // 初始化
    _init();
  }

  void _init() async {
    print(await HotkeyShortcuts.platformVersion);
    HotkeyShortcuts.register("command+shift+r", () async {
      print("hotkey entered");
      await WindowActivator.activateWindow();
    });
  }
}
