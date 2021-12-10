import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_result_item.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/views/input_bar.dart';
import 'package:public_tools/views/list_preview.dart';
import 'package:window_manager/window_manager.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  List<PluginListResultItem> list = [];

  int selectedIndex = 0;
  PluginListResultItem _curResultItem;
  bool _loading = false;
  HotKey _hotKey = HotKey(
    KeyCode.space,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.system,
  );

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 注册快捷键
    hotKeyManager.register(
      _hotKey,
      keyDownHandler: (hotKey) async {
        _textEditingController.clear();
        await windowManager.show();
      },
    );
    PluginManager.instance.onEnterItem = (item) {
      setState(() {
        _curResultItem = item;
        _textEditingController.clear();
        list.clear();
        selectedIndex = 0;
      });
    };
    PluginManager.instance.onLoading = (isLoading) {
      setState(() {
        _loading = isLoading;
      });
    };
    _textEditingController.addListener((() {
      // 实践当知，这里要判断是否同值
      String lastText = "";
      return () {
        if (lastText == _textEditingController.text) {
          return;
        }
        lastText = _textEditingController.text;
        _onKeywordChange();
      };
    })());
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
    print("aaaa");
  }

  void _onKeywordChange() {
    setState(() {
      selectedIndex = 0;
    });
    final keyword = _textEditingController.text;
    PluginManager.instance.handleInput(
      keyword,
      this._setPluginResult,
      this._clearResultList,
    );
  }

  void _updateWindowSize() {
    var listLength = list.length;
    var windowHeight = ((listLength > 9 ? 9 : listLength) * 48) + 48;
    var windowWidth = 720;
    // HotkeyShortcuts.updateWindowSize(width: windowWidth, height: windowHeight);
  }

  void _clearResultList() {
    setState(() {
      list.clear();
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _setPluginResult(List<PluginListResultItem> result, Plugin plugin) {
    setState(() {
      // 用替换法，可以避免闪烁
      final startIndex = list.indexWhere((element) => element.plugin == plugin);
      final endIndex =
          list.lastIndexWhere((element) => element.plugin == plugin);
      if (startIndex != -1) {
        list.removeRange(startIndex, endIndex + 1);
        list.insertAll(startIndex, result);
      } else {
        list.addAll(result);
      }
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _onEnter() {
    if (list.length == 0) return;
    PluginManager.instance.handleTap(list[selectedIndex]);
  }

  void _selectNext() {
    var nextIndex = (this.selectedIndex + 1) % list.length;
    setState(() {
      selectedIndex = nextIndex;
    });
  }

  void _selectPrev() {
    var prevIndex = (this.selectedIndex - 1 + list.length) % list.length;
    setState(() {
      selectedIndex = prevIndex;
    });
  }

  void _onTap(PluginListItem item, Plugin plugin) {
    _textEditingController.clear();
  }

  void _exitResultItem() {
    PluginManager.instance.exitResultItem();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                InputBar(
                  controller: _textEditingController,
                  onEnter: this._onEnter,
                  selectNext: this._selectNext,
                  selectPrev: this._selectPrev,
                  curResultItem: this._curResultItem,
                  onExitResultItem: this._exitResultItem,
                ),
                LinearProgressIndicator(
                  backgroundColor: Colors.black12,
                  color: Colors.black26,
                  minHeight: 1,
                  value: _loading ? null : 0,
                ),
                Expanded(
                  child: PluginListView(
                      list: list, onTap: _onTap, selectedIndex: selectedIndex),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
