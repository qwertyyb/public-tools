import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortcut_launcher/plugins/settings/setting_key.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';
import '../../core/plugin_manager.dart';
import '../../main.dart';
import '../../pages/main_page.dart';
import '../../utils/logger.dart';
import 'basic_settings.dart';
import 'plugin_settings.dart';

void _refreshHotKey() async {
  logger.i('setting._refreshHotKey');
  await HotKeyManager.instance.unregisterAll();
  final prefs = await SharedPreferences.getInstance();
  var mainHotKey = prefs.getString(SettingKey.mainHotKey);
  if (mainHotKey == null || mainHotKey == '') {
    final defaultHotKey = jsonEncode(HotKey(KeyCode.space,
        modifiers: [KeyModifier.meta], scope: HotKeyScope.system));
    prefs.setString(SettingKey.mainHotKey, defaultHotKey);
    mainHotKey = defaultHotKey;
  }
  HotKeyManager.instance.register(
    HotKey.fromJson(jsonDecode(mainHotKey)),
    keyDownHandler: (hotKey) async {
      await windowManager.show();
    },
  );
  final pluginsHotKey = prefs.getString(SettingKey.pluginsCommandsHotKey);
  if (pluginsHotKey == null || pluginsHotKey == '') return;
  final json = jsonDecode(pluginsHotKey) as Map<String, dynamic>;
  json.forEach((pluginId, value) {
    final commandsHotKey = (value as Map).map<String, HotKey>(
        (key, value) => MapEntry(key, HotKey.fromJson(value)));
    commandsHotKey.forEach((commandId, hotKey) {
      HotKeyManager.instance.register(
        hotKey,
        keyDownHandler: (hotKey) async {
          logger.i('hotkey trigger: hotkey: ${hotKey.toJson()}');
          final plugin = PluginManager.instance.plugins
              .firstWhereOrNull((element) => element.id == pluginId);
          final command = plugin?.commands
              .firstWhereOrNull((element) => element.id == commandId);
          if (command == null) return;
          PluginManager.instance.onCommand(command, plugin!);
          await windowManager.show();
        },
      );
    });
  });
}

EventChannel _eventChannel = EventChannel("events-listener");
Timer? _timer;
void _startListenEvents() {
  _eventChannel.receiveBroadcastStream().listen((event) async {
    if (event == 'DID_HIDE') {
      final prefs = await SharedPreferences.getInstance();
      final duration = prefs.getInt(SettingKey.exitCommandDuration) ?? 10;
      if (duration < 0) return;
      _timer = Timer(Duration(seconds: duration), () {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        MainPageState.current?.searchListKey.currentState?.clearSearch();
      });
    } else if (event == 'WILL_UNHIDE') {
      _timer?.cancel();
    }
  });
}

final _command = PluginCommand(
  id: 'settings',
  title: '设置',
  subtitle: 'Public设置',
  icon: 'https://img.icons8.com/color/96/000000/settings--v1.png',
  mode: CommandMode.listView,
  keywords: ["settings", "preferences", "设置", "sz"],
  onSearch: (String keyword) {
    final basicItem = SearchResult(
      id: 'basic',
      title: "基础",
      subtitle: '基础设置',
      description: 'basic',
    );
    final hotkeyItem = SearchResult(
      id: 'plugins',
      title: '快捷键',
      subtitle: '插件快捷键',
      description: 'plugins',
    );
    return Future.value([
      basicItem,
      hotkeyItem,
    ]);
  },
  onResultPreview: (SearchResult result) {
    if (result.id == 'basic')
      return Future.value(BasicSettingsView(
        onHotKeyChange: _refreshHotKey,
      ));
    if (result.id == 'plugins')
      return Future.value(PluginSettingsView(
        onHotKeyChange: _refreshHotKey,
      ));
    return Future.value(null);
  },
);

final settingsPlugin = Plugin(
  title: '设置',
  subtitle: 'Public设置',
  description: '设置',
  icon: '',
  id: 'settings',
  commands: [_command],
  onRegister: () {
    _refreshHotKey();
    _startListenEvents();
  },
);
