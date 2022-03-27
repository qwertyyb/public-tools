import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';
import '../../core/plugin_manager.dart';
import '../../utils/logger.dart';
import 'basic_settings.dart';
import 'plugin_settings.dart';

void _refreshHotKey() async {
  logger.i('setting._refreshHotKey');
  await HotKeyManager.instance.unregisterAll();
  final prefs = await SharedPreferences.getInstance();
  var mainHotKey = prefs.getString('mainHotKey');
  if (mainHotKey == null || mainHotKey == '') {
    final defaultHotKey = jsonEncode(HotKey(KeyCode.space,
        modifiers: [KeyModifier.meta], scope: HotKeyScope.system));
    prefs.setString('mainHotKey', defaultHotKey);
    mainHotKey = defaultHotKey;
  }
  HotKeyManager.instance.register(
    HotKey.fromJson(jsonDecode(mainHotKey)),
    keyDownHandler: (hotKey) async {
      await windowManager.show();
    },
  );
  final pluginsHotKey = prefs.getString('pluginsHotKey');
  if (pluginsHotKey == null || pluginsHotKey == '') return;
  final json = jsonDecode(pluginsHotKey) as Map<String, dynamic>;
  json.forEach((key, value) {
    final hotKey = HotKey.fromJson(value);
    HotKeyManager.instance.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        logger.i('hotkey trigger: hotkey: ${hotKey.toJson()}');
        final plugin = PluginManager.instance.plugins
            .firstWhereOrNull((element) => element.id == key);
        if (plugin == null) return;
        PluginManager.instance.onCommand(plugin.commands.first, plugin);
        await windowManager.show();
      },
    );
  });
}

final _command = PluginCommand(
  id: 'settings',
  title: '设置',
  subtitle: 'Public设置',
  icon: '',
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
  onRegister: _refreshHotKey,
);
