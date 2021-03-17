import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';

class InputBar extends StatelessWidget {
  final Function onEnter;
  final FocusNode _focusNode = FocusNode(canRequestFocus: false);

  final TextEditingController controller;

  InputBar({this.onEnter, this.controller});

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
    // 当按下向下键时，自动聚焦到下一个可聚焦的组件上，一般是候选列表第一个
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      // 第一个在输入时是选中状态，所以跳过第一个，直接跳去第二个
      FocusManager.instance.primaryFocus.nextFocus();
      FocusManager.instance.primaryFocus.nextFocus();
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      this.onEnter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: RawKeyboardListener(
        onKey: _onKey,
        focusNode: _focusNode,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerUp,
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 32),
            controller: controller,
          ),
        ),
      ),
    );
  }
}
