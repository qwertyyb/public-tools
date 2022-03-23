import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/utils/logger.dart';
import 'package:public_tools/views/input_bar.dart';
import 'package:public_tools/views/list_preview.dart';

class SearchList<T> extends StatefulWidget {
  final Future<List> Function(String keyword) onSearch;

  final Future<Widget> Function(T item) onSelect;

  final void Function(T item) onEnter;

  final void Function() onEmptyDelete;

  final Widget inputPrefix;

  final Widget inputSuffix;

  SearchList({
    this.onSearch,
    this.onEnter,
    this.onSelect,
    this.inputPrefix,
    this.inputSuffix,
    this.onEmptyDelete,
  });

  @override
  State<StatefulWidget> createState() => _SearchListState<T>();
}

class _SearchListState<T> extends State<SearchList<T>> {
  bool _loading = false;
  final TextEditingController _textEditingController = TextEditingController();
  List<T> _list = [];
  int _selectedIndex = 0;

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
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  void _onKeywordChange() async {
    final keyword = _textEditingController.text;
    final list = await widget.onSearch(keyword);
    setState(() {
      _list = list;
      _selectedIndex = 0;
    });
  }

  void _selectNext() {
    final nextIndex = (_selectedIndex + 1) % _list.length;
    setState(() {
      _selectedIndex = nextIndex;
    });
  }

  void _selectPrevious() {
    final nextIndex = (_selectedIndex - 1 + _list.length) % _list.length;
    setState(() {
      _selectedIndex = nextIndex;
    });
  }

  void _onEnter() {
    final selected = _list[_selectedIndex];
    widget.onEnter(selected);
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
                  onEmptyDelete: this.widget.onEmptyDelete,
                  selectNext: this._selectNext,
                  selectPrev: this._selectPrevious,
                  inputPrefix: widget.inputPrefix,
                  inputSuffix: widget.inputSuffix,
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
                    onTap: _onEnter,
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
