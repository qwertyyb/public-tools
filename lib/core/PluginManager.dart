import 'package:ypaste_flutter/core/Plugin.dart';

import 'PluginListItem.dart';

class PluginManager {
  // 工厂模式
  factory PluginManager() => _getInstance();
  static PluginManager get instance => _getInstance();
  static PluginManager _instance;
  PluginManager._internal() {
    // 初始化
  }

  static PluginManager _getInstance() {
    if (_instance == null) {
      _instance = new PluginManager._internal();
    }
    return _instance;
  }

  List<Plugin> _pluginList = [];
  void register(Plugin plugin) {
    plugin.onCreated();
    _pluginList.add(plugin);
  }

  void handleInput(
    String keyword,
    void Function(Plugin plugin, List<PluginListItem> list) setResult,
  ) {
    var setPluginResult = (Plugin plugin) {
      return (List<PluginListItem> list) {
        setResult(plugin, list);
      };
    };
    _pluginList.forEach((plugin) {
      plugin.onInput(keyword, setPluginResult(plugin));
    });
  }
}
