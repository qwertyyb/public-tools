import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:public_tools/core/plugin_result_item.dart';
import 'package:public_tools/views/plugin_label_view.dart';
import 'package:window_manager/window_manager.dart';

class _TextInput extends StatelessWidget {
  final TextEditingController controller;

  final void Function() onArrowDown;

  final void Function() onArrowUp;

  final void Function() onEnter;

  final void Function() onEmptyDelete;

  final bool spaceOnEnter;

  FocusNode _focusNode;

  _TextInput({
    this.controller,
    this.onArrowDown,
    this.onEnter,
    this.onArrowUp,
    this.spaceOnEnter,
    this.onEmptyDelete,
  }) {
    _focusNode = FocusNode(
        canRequestFocus: false,
        onKey: (node, event) {
          // 防止按向上或向下箭头时，光标移动
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
              event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
              (spaceOnEnter && event.isKeyPressed(LogicalKeyboardKey.space)) ||
              event.isKeyPressed(LogicalKeyboardKey.enter)) {
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        });
  }

  void _onKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      this.onArrowDown();
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
        (spaceOnEnter && event.isKeyPressed(LogicalKeyboardKey.space))) {
      this.onEnter();
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      this.onArrowUp();
    } else if (event.isKeyPressed(LogicalKeyboardKey.backspace) &&
        controller.text.length <= 0) {
      this.onEmptyDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: _onKey,
      focusNode: _focusNode,
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: "What Do You Want?",
        ),
        style: TextStyle(fontSize: 20),
        controller: controller,
      ),
    );
  }
}

class InputBar extends StatelessWidget {
  final Function onEnter;
  final Function selectNext;
  final Function selectPrev;
  final PluginListResultItem curResultItem;
  final Function onExitResultItem;

  final TextEditingController controller;

  InputBar({
    this.onEnter,
    this.controller,
    this.selectNext,
    this.selectPrev,
    this.onExitResultItem,
    this.curResultItem,
  });

  void _onPointerDown(PointerDownEvent event) {
    windowManager.startDragging();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [
      Expanded(
        child: _TextInput(
          controller: controller,
          onEnter: onEnter,
          onArrowDown: selectNext,
          onArrowUp: selectPrev,
          spaceOnEnter: curResultItem == null,
          onEmptyDelete: onExitResultItem,
        ),
      ),
    ];
    if (curResultItem != null) {
      widgets.insert(
        0,
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: onExitResultItem,
          icon: Icon(Icons.arrow_back_ios),
        ),
      );
      widgets.add(PluginLabelView(
          icon: curResultItem.result.icon, title: curResultItem.result.title));
    }
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Listener(
        onPointerDown: _onPointerDown,
        child: Row(
          children: widgets,
        ),
      ),
    );
  }
}
