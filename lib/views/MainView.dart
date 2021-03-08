import 'package:flutter/material.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:ypaste_flutter/core/Plugin.dart';
import 'package:ypaste_flutter/core/PluginListItem.dart';
import 'package:ypaste_flutter/core/PluginManager.dart';
import 'package:ypaste_flutter/views/InputBar.dart';
import 'package:ypaste_flutter/views/PluginView.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Map<Plugin, List<PluginListItem>> list = Map<Plugin, List<PluginListItem>>();

  @override
  void initState() {
    super.initState();
  }

  void _onKeywordChange(String keyword) {
    PluginManager.instance.handleInput(keyword, this._setPluginResult);
  }

  void _updateWindowSize() {
      var listLength = list.values.expand((element) => element).length;
      var windowHeight = ((listLength > 9 ? 9 : listLength) * 54) + 60;
      var windowWidth = 720;
      HotkeyShortcuts.updateWindowSize(width: windowWidth, height: windowHeight);
  }

  void _setPluginResult(Plugin plugin, List<PluginListItem> result) {
    setState(() {
      list[plugin] = result;
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemBuilder: (pluginContext, pluginIndex) {
        var plugin = list.keys.elementAt(pluginIndex);
        return PluginView(
          plugin: plugin,
          results: list[plugin],
        );
      },
      itemCount: list.keys.length,
    );
    return Column(
      children: [
        InputBar(onKeywordChange: this._onKeywordChange,),
        Expanded(
          child: listView,
        )
      ],
    );
  }
}
