import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/plugins/application/application.dart';
import 'package:public_tools/plugins/clipboard/clipboard.dart';
import 'package:public_tools/plugins/command/command.dart';
import 'package:public_tools/plugins/remote/remote.dart';

import 'plugin_result_item.dart';

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

  String _curKeyword = "";
  PluginListResultItem _curResultItem;
  void Function(PluginListResultItem) onEnterItem;
  void Function(bool isLoading) onLoading;

  List<Plugin> _corePluginList = [
    CommandPlugin(),
    ClipboardPlugin(),
    ApplicationPlugin(),
    RemotePlugin()
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
    void Function(List<PluginListResultItem> list) setResult,
    void Function() clearResult,
  ) {
    print("query: $keyword");
    _curKeyword = keyword;
    if (keyword == "") {
      clearResult();
      return;
    }
    var setPluginResult = ((String keyword) {
      return (Plugin plugin) {
        bool called = false;
        return (List<PluginListItem> list) {
          // 每个keyword, setResult最多只能调用一次
          if (keyword != _curKeyword || called) {
            return null;
          }
          called = true;
          var resultList = list.map((item) {
            return PluginListResultItem(plugin: plugin, result: item);
          }).toList();
          setResult(resultList);
        };
      };
    })(keyword);
    if (_curResultItem == null) {
      _pluginList.forEach((plugin) {
        plugin.onQuery(keyword, setPluginResult(plugin));
      });
    } else {
      _curResultItem.plugin.setLoading = onLoading;
      _curResultItem.plugin
          .onQuery(keyword, setPluginResult(_curResultItem.plugin));
    }
  }

  void handleTap(PluginListResultItem item) {
    item.onTap(onEnterItem: () {
      _curResultItem = item;
      onEnterItem(item);
    });
  }

  void exitResultItem() {
    _curResultItem.plugin.onExit(_curResultItem.result);
    _curResultItem = null;
    onEnterItem(null);
  }
}
