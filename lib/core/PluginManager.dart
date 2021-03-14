import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/plugins/application/application.dart';
import 'package:public_tools/plugins/clipboard.dart';
import 'package:public_tools/plugins/command/command.dart';

import 'PluginListItem.dart';

class PluginManager {
  // 工厂模式
  factory PluginManager() => _getInstance();
  static PluginManager get instance => _getInstance();
  static PluginManager _instance;
  static PluginManager _getInstance() {
    if (_instance == null) {
      _instance = new PluginManager._internal();
    }
    return _instance;
  }

  List<Plugin> _corePluginList = [
    CommandPlugin(),
    ClipboardPlugin(),
    ApplicationPlugin(),
  ];

  PluginManager._internal() {
    // 初始化
    _corePluginList.forEach((plugin) => register(plugin));
  }

  List<Plugin> _pluginList = [];
  void register(Plugin plugin) {
    _pluginList.add(plugin);
  }

  void handleInput(
    String keyword,
    void Function(Plugin plugin, List<PluginListItem> list) setResult,
    void Function() clearResult,
  ) {
    print("query: $keyword");
    if (keyword == "") {
      clearResult();
      return;
    }
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
