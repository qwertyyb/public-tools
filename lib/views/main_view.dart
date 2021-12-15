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
  Widget preview;

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
    PluginManager.instance.onResultChange = (resultList) {
      print('onResultChange: ${resultList.length}');
      _list = resultList;
      _updatePreview();
    };
    PluginManager.instance.onEnterItem = (item) {
      print('onEnter before');
      _selectedIndex = 0;
      _updatePreview();
      setState(() {
        _curResultItem = item;
        // 会同步触发onChange，所以要放在最后，在onChange中能拿到最新的值
        _textEditingController.clear();
      });
    };
    PluginManager.instance.onPreviewChange = (previewWidget) {
      setState(() {
        preview = previewWidget;
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

  void _updatePreview() {
    print('$_selectedIndex, ${_list.length}');
    if (_selectedIndex < _list.length) {
      final selected = _list.elementAt(_selectedIndex);
      PluginManager.instance.handleResultSelected(selected);
    } else {
      preview = null;
    }
    setState(() {});
  }

  void _onKeywordChange() {
    _selectedIndex = 0;
    _updatePreview();
    final keyword = _textEditingController.text;
    PluginManager.instance.handleInput(keyword);
  }

  void _updateWindowSize() {
    var listLength = _list.length;
    var windowHeight = ((listLength > 9 ? 9 : listLength) * 48) + 48;
    var windowWidth = 720;
    // HotkeyShortcuts.updateWindowSize(width: windowWidth, height: windowHeight);
  }

  void _onEnter() {
    if (_list.length == 0) return;
    PluginManager.instance.handleTap(_list[_selectedIndex]);
  }

  void _selectNext() {
    var nextIndex = (this._selectedIndex + 1) % _list.length;
    _selectedIndex = nextIndex;
    _updatePreview();
  }

  void _selectPrev() {
    var prevIndex = this._selectedIndex <= 1 ? 0 : this._selectedIndex - 1;
    _selectedIndex = prevIndex;
    _updatePreview();
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
                    preview: preview,
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
