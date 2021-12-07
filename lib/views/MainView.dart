import 'package:flutter/material.dart';
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
  List<PluginListResultItem> list = [];

  int selectedIndex = 0;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
  }

  void _onKeywordChange() {
    setState(() {
      list.clear();
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

  void _setPluginResult(List<PluginListResultItem> result) {
    setState(() {
      list.addAll(result);
      // 设置一个计时器，等组件渲染完成再调整窗口大小，否则会导致窗口闪烁
      Future.delayed(Duration(milliseconds: 100), () => _updateWindowSize());
    });
  }

  void _onEnter() {
    if (list.length == 0) return;
    list[selectedIndex].onTap();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputBar(
          controller: _textEditingController,
          onEnter: this._onEnter,
          selectNext: this._selectNext,
          selectPrev: this._selectPrev,
        ),
        Divider(
          height: 0,
        ),
        Expanded(
          child: PluginListView(
              list: list, onTap: _onTap, selectedIndex: selectedIndex),
        ),
      ],
    );
  }
}
