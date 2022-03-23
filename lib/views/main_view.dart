import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/utils/logger.dart';
import 'package:public_tools/views/input_bar.dart';
import 'package:public_tools/views/list_preview.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Timer _clearStateTimer;
  EventChannel _eventChannel = EventChannel("events-listener");

  bool _loading = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener((() {
      // 实践当知，这里要判断是否同值
      String lastText = "";
      return () {
        logger.i("text changed: ${_textEditingController.text}");
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
          PluginManager.instance.onExit();
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
    final keyword = _textEditingController.text;
    PluginManager.instance.onSearch(keyword);
  }

  void _onEnter() {
    PluginManager.instance.onTap();
  }

  void _selectNext() {
    PluginManager.instance.selectNext();
  }

  void _selectPrev() {
    PluginManager.instance.selectPrevious();
  }

  void _onTap(item, Plugin plugin) {
    _textEditingController.clear();
  }

  void _exitResultItem() {
    PluginManager.instance.onExit();
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
                ),
                LinearProgressIndicator(
                  backgroundColor: Colors.black12,
                  color: Colors.black26,
                  minHeight: 1,
                  value: _loading ? null : 0,
                ),
                Expanded(
                  child: PluginListView(
                    list: context.select((MainState state) => state.list),
                    onTap: _onTap,
                    selectedIndex: context
                        .select((MainState state) => state.selectedIndex),
                    preview: context
                        .select((MainState state) => state.resultPreview),
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
