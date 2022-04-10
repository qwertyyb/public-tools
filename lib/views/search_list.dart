import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/logger.dart';
import 'input_bar.dart';
import 'search_result_list.dart';

class SearchList<T> extends StatefulWidget {
  final Future<List> Function(String keyword) onSearch;

  final Future<Widget?>? Function(T item)? onSelect;

  final void Function(T item)? onEnter;

  final void Function()? onEmptyDelete;

  final Widget? inputPrefix;

  final Widget? inputSuffix;

  final bool searchAtStart;

  SearchList(
      {Key? key,
      required this.onSearch,
      this.onEnter,
      this.onSelect,
      this.inputPrefix,
      this.inputSuffix,
      this.onEmptyDelete,
      this.searchAtStart = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SearchListState<T>();
}

class SearchListState<T> extends State<SearchList<T>> {
  bool _loading = false;
  final TextEditingController _textEditingController = TextEditingController();
  List<T> _list = [];
  int _selectedIndex = 0;
  Widget? preview;

  void updateResults(List<T> results) {
    setState(() {
      _list = results;
      _selectedIndex = 0;
    });
    this._updatePreview(results.isNotEmpty ? results[0] : null);
  }

  void clearSearch() {
    _textEditingController.clear();
  }

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
    if (widget.searchAtStart) {
      _onKeywordChange();
    }
  }

  @override
  void dispose() {
    logger.i('dispose');
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  void _updatePreview(selected) async {
    if (selected == null) {
      setState(() {
        preview = null;
      });
      return;
    }
    final selectedPreview = await widget.onSelect?.call(selected)!;
    final latestSelected =
        _selectedIndex < _list.length ? _list[_selectedIndex] : null;
    // 当前预览和选中的不一致，不更新状态
    if (selected != latestSelected) {
      return;
    }
    setState(() {
      preview = selectedPreview;
    });
  }

  void _onKeywordChange() async {
    setState(() {
      _loading = true;
    });
    final keyword = _textEditingController.text;
    logger.i('keyword: $keyword');
    final list = await widget.onSearch(keyword).catchError((e) {
      logger.e('onSearch error: $e');
      return [];
    });
    // 关键词已变化，返回的结果不是当前的关键词结果，不更新状态
    if (keyword != _textEditingController.text) {
      return;
    }
    setState(() {
      _list = list as List<T>;
      _selectedIndex = 0;
      _loading = false;
    });
    _updatePreview(list.isNotEmpty ? list[0] : null);
  }

  void _selectNext() {
    if (_list.length == 0) {
      return;
    }
    final nextIndex = (_selectedIndex + 1) % _list.length;
    setState(() {
      _selectedIndex = nextIndex;
    });
    _updatePreview(_list[nextIndex]);
  }

  void _selectPrevious() {
    if (_list.length == 0) {
      return;
    }
    final nextIndex = (_selectedIndex - 1 + _list.length) % _list.length;
    setState(() {
      _selectedIndex = nextIndex;
    });
    _updatePreview(_list[nextIndex]);
  }

  void _onEnter() {
    if (_selectedIndex >= _list.length) {
      return;
    }
    final selected = _list[_selectedIndex];
    widget.onEnter?.call(selected);
  }

  void _onItemTap(T item, int index) {
    _selectedIndex = index;
    _updatePreview(item);
    _onEnter();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.transparent,
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SearchResultList<T>(
                          list: _list,
                          onTap: _onItemTap,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                      if (preview != null)
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: double.infinity,
                            padding: EdgeInsets.zero,
                            color: Color.fromARGB(49, 165, 165, 165),
                            child: Expanded(
                              child: preview!,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
