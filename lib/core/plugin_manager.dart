import 'package:flutter/widgets.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/plugins/application/application.dart';
import 'package:public_tools/plugins/clipboard/clipboard.dart';
import 'package:public_tools/plugins/command/command.dart';
import 'package:public_tools/plugins/remote/remote.dart';
import 'package:public_tools/plugins/settings/settings_plugin.dart';
import 'package:public_tools/utils/logger.dart';

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

  Map<Plugin, List<PluginListResultItem>> _resultList = {};
  PluginListResultItem _curResultItem;
  void Function(PluginListResultItem) onEnterItem;
  void Function(List<PluginListResultItem> resultList) onResultChange =
      (List<PluginListResultItem> resultList) {};
  void Function(Widget preview) onPreviewChange = (preview) {};
  void Function(bool isLoading) onLoading;

  void _updateResultList(void Function() updater) {
    updater();
    onResultChange(_resultList.values.expand((element) => element).toList());
  }

  List<Plugin> _corePluginList = [
    SettingsPlugin(),
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

  void handleInput(String keyword) {
    logger.i('[handleInput] keyword: $keyword');
    if (_curResultItem == null && keyword == "") {
      _updateResultList(() => _resultList.clear());
      return;
    }
    var setPluginResult = (Plugin plugin) {
      return (List<PluginListItem> list) {
        var resultList = list.map((item) {
          return PluginListResultItem(plugin: plugin, result: item);
        }).toList();
        _updateResultList(() => _resultList[plugin] = resultList);
      };
    };
    if (_curResultItem == null) {
      _pluginList.forEach((plugin) {
        plugin.onQuery(keyword, setPluginResult(plugin));
      });
    } else {
      _curResultItem.plugin.setLoading = onLoading;
      _curResultItem.plugin
          .onSearch(keyword, setPluginResult(_curResultItem.plugin));
    }
  }

  void handleTap(PluginListResultItem item) {
    if (_curResultItem == null) {
      item.plugin.onTap(item.result, enterItem: () {
        _curResultItem = item;
        _updateResultList(() => _resultList.clear());
        item.plugin.onEnter(item.result);
        onEnterItem(item);
      });
    } else {
      item.plugin.onResultTap(item.result);
    }
  }

  void handleResultSelected(PluginListResultItem item) {
    if (_curResultItem == null) {
      return null;
    } else {
      return item.plugin
          .onResultSelect(item.result, setPreview: onPreviewChange);
    }
  }

  void exitResultItem() {
    if (_curResultItem == null) return;
    _curResultItem.plugin.onExit(_curResultItem.result);
    _curResultItem = null;
    _updateResultList(() => _resultList.clear());
    onEnterItem(null);
  }
}
