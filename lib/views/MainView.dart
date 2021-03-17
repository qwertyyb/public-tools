import 'package:flutter/material.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/core/PluginManager.dart';
import 'package:public_tools/views/InputBar.dart';
import 'package:public_tools/views/PluginListView.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Map<Plugin, List<PluginListItem>> list = Map<Plugin, List<PluginListItem>>();

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_onKeywordChange);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _onKeywordChange() {
    final keyword = _textEditingController.text;
    PluginManager.instance.handleInput(
      keyword,
      this._setPluginResult,
      this._clearResultList,
    );
  }

  void _updateWindowSize() {
    var listLength = list.values.expand((element) => element).length;
    var windowHeight = ((listLength > 9 ? 9 : listLength) * 54) + 60;
    var windowWidth = 720;
    HotkeyShortcuts.updateWindowSize(width: windowWidth, height: windowHeight);
  }

  void _clearResultList() {
    setState(() {
      list = {};
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _setPluginResult(Plugin plugin, List<PluginListItem> result) {
    setState(() {
      list[plugin] = result;
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _onEnter() {
    final plugin = list.keys.first;
    plugin.onTap(list[plugin].first);
  }

  void _onTap(PluginListItem item, Plugin plugin) {
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputBar(
          controller: _textEditingController,
          onEnter: this._onEnter,
        ),
        Divider(
          height: 0,
        ),
        Expanded(
          child: PluginListView(
            list: list,
            onTap: _onTap,
          ),
        ),
      ],
    );
  }
}
