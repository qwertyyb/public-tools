import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';

class InputBar extends StatelessWidget {
  final Function onEnter;
  final Function selectNext;
  final Function selectPrev;

  final FocusNode _focusNode = FocusNode(
      canRequestFocus: false,
      onKey: (node, event) {
        // 防止按向上或向下箭头时，光标移动
        if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
            event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      });

  final TextEditingController controller;

  InputBar({this.onEnter, this.controller, this.selectNext, this.selectPrev});

  void _onPointerMove(PointerMoveEvent event) {
    // 经过实践，此事件返回的位置信息乱七八糟，计算出来的位移信息会有瞬移的情况
    // 所以此接口获取到的位移信息dx, dy不作为窗口移动的依据。
    HotkeyShortcuts.moveWindowPosition(dx: event.delta.dx, dy: event.delta.dy);
  }

  void _onPointerDown(PointerDownEvent event) {
    HotkeyShortcuts.recordWindowPosition();
  }

  void _onPointerUp(PointerEvent event) {}

  void _onKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      this.selectNext();
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      this.onEnter();
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      this.selectPrev();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: RawKeyboardListener(
        onKey: _onKey,
        focusNode: _focusNode,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: TextField(
            // textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 20),
            controller: controller,
          ),
        ),
      ),
    );
  }
}
