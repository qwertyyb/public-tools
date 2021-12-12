import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  HotKey _hotKey = HotKey(
    KeyCode.space,
    modifiers: [KeyModifier.meta],
    scope: HotKeyScope.system,
  );
  Timer _clearStateTimer;
  EventChannel _eventChannel = EventChannel("events-listener");

  List<PluginListResultItem> _list = [];
  int _selectedIndex = 0;
  PluginListResultItem _curResultItem;
  bool _loading = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 注册快捷键
    hotKeyManager.register(
      _hotKey,
      keyDownHandler: (hotKey) async {
        await windowManager.show();
      },
    );
    PluginManager.instance.onEnterItem = (item) {
      print('onEnter before');
      setState(() {
        _curResultItem = item;
        _list.clear();
        _selectedIndex = 0;
        // 会同步触发onChange，所以要放在最后，在onChange中能拿到最新的值
        _textEditingController.clear();
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
    _eventChannel.receiveBroadcastStream("state").listen((event) {
      if (event == 'DID_HIDE') {
        _clearStateTimer = Timer(Duration(minutes: 1), () {
          PluginManager.instance.exitResultItem();
          _clearResultList();
          setState(() {
            _textEditingController.clear();
            _loading = false;
          });
        });
      } else if (event == 'WILL_UNHIDE') {
        if (_clearStateTimer != null) {
          _clearStateTimer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  void _onKeywordChange() {
    setState(() {
      _selectedIndex = 0;
    });
    final keyword = _textEditingController.text;
    PluginManager.instance.handleInput(
      keyword,
      this._setPluginResult,
      this._clearResultList,
    );
  }

  void _updateWindowSize() {
    var listLength = _list.length;
    var windowHeight = ((listLength > 9 ? 9 : listLength) * 48) + 48;
    var windowWidth = 720;
    // HotkeyShortcuts.updateWindowSize(width: windowWidth, height: windowHeight);
  }

  void _clearResultList() {
    setState(() {
      _list.clear();
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _setPluginResult(List<PluginListResultItem> result, Plugin plugin) {
    setState(() {
      // 用替换法，可以避免闪烁
      final startIndex =
          _list.indexWhere((element) => element.plugin == plugin);
      final endIndex =
          _list.lastIndexWhere((element) => element.plugin == plugin);
      if (startIndex != -1) {
        _list.removeRange(startIndex, endIndex + 1);
        _list.insertAll(startIndex, result);
      } else {
        _list.addAll(result);
      }
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _onEnter() {
    if (_list.length == 0) return;
    PluginManager.instance.handleTap(_list[_selectedIndex]);
  }

  void _selectNext() {
    var nextIndex = (this._selectedIndex + 1) % _list.length;
    setState(() {
      _selectedIndex = nextIndex;
    });
  }

  void _selectPrev() {
    var prevIndex = this._selectedIndex <= 1 ? 0 : this._selectedIndex - 1;
    setState(() {
      _selectedIndex = prevIndex;
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
                    list: _list,
                    onTap: _onTap,
                    selectedIndex: _selectedIndex,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
