import 'package:flutter/material.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';

class InputBar extends StatelessWidget {

  final Function onKeywordChange;

  InputBar({ this.onKeywordChange });

  void _onPointerMove(PointerMoveEvent event) {
    // 经过实践，此事件返回的位置信息乱七八糟，计算出来的位移信息会有瞬移的情况
    // 所以此接口获取到的位移信息dx, dy不作为窗口移动的依据。
    HotkeyShortcuts.moveWindowPosition(
      dx: event.delta.dx,
      dy: event.delta.dy
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    HotkeyShortcuts.recordWindowPosition();
  }

  void _onPointerUp(PointerEvent event) {
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
        child: TextField(
          style: TextStyle(
            fontSize: 24,
          ),
          onChanged: this.onKeywordChange,
        ),
      ),
    );
  }
}