import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/plugins/settings/basic.dart';
import 'package:public_tools/plugins/settings/hot_key.dart';
import 'package:public_tools/plugins/settings/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPlugin extends Plugin {
  List<PluginCommand> commands = [
    PluginCommand(
      title: '设置',
      subtitle: 'Public设置',
      icon: null,
      mode: CommandMode.listView,
      keywords: ["settings", "preferences", "设置", "sz"],
    )
  ];

  SettingsPlugin() {
    this._refreshHotkey();
  }

  @override
  void onEnter(PluginCommand item) {}

  @override
  Future<List<SearchResult>> onSearch(
    String keyword,
    PluginCommand command,
  ) {
    final basicItem =
        SearchResult(title: "基础", subtitle: '基础设置', description: 'basic');
    final hotkeyItem =
        SearchResult(title: '快捷键', subtitle: '插件快捷键', description: 'hotkey');
    return Future.value([
      basicItem,
      hotkeyItem,
    ]);
  }

  void _refreshHotkey() async {
    await HotKeyManager.instance.unregisterAll();
    final hotkey = await getHotkeyFromPrefs();
    HotKeyManager.instance.register(
      hotkey,
      keyDownHandler: (hotKey) async {
        await windowManager.show();
      },
    );
    final prefs = await SharedPreferences.getInstance();
    final pluginsHotKey = prefs.getString('pluginsHotKey');
    if (pluginsHotKey == null || pluginsHotKey == '') return;
    final json = jsonDecode(pluginsHotKey) as Map<String, dynamic>;
    json.forEach((key, value) {
      final hotKey = HotKey.fromJson(value);
      HotKeyManager.instance.register(
        hotKey,
        keyDownHandler: (hotKey) async {
          final plugin = PluginManager.instance
              .getPlugins()
              .firstWhere((element) => element.id == key, orElse: () => null);
          if (plugin == null) return;
          PluginManager.instance.onCommand(PluginResult<PluginCommand>(
              plugin: plugin, value: plugin.commands.first));
          await windowManager.show();
        },
      );
    });
  }

  @override
  Future<Widget> onResultSelected(SearchResult item) {
    if (item.description == 'basic')
      return Future.value(BasicView(
        onHotkeyChange: this._refreshHotkey,
      ));
    if (item.description == 'hotkey') return Future.value(HotKeyView());
    return null;
  }
}
