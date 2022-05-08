import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

typedef void OnKey();

class _TextInput extends StatelessWidget {
  final TextEditingController? controller;

  final OnKey? onArrowDown;

  final OnKey? onArrowUp;

  final OnKey? onEnter;

  final OnKey? onEmptyDelete;

  final OnKey? onSpace;

  final FocusNode _focusNode;

  _TextInput({
    this.controller,
    this.onArrowDown,
    this.onEnter,
    this.onArrowUp,
    this.onEmptyDelete,
    this.onSpace,
  }) : _focusNode = FocusNode(
          canRequestFocus: false,
          onKey: (node, event) {
            // 防止按向上或向下箭头时，光标移动
            if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) ||
                event.isKeyPressed(LogicalKeyboardKey.arrowUp) ||
                event.isKeyPressed(LogicalKeyboardKey.enter)) {
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
        );

  void _onKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      this.onArrowDown!();
    } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      this.onEnter!();
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      this.onArrowUp!();
    } else if (event.isKeyPressed(LogicalKeyboardKey.space)) {
      this.onSpace?.call();
    } else if (event.isKeyPressed(LogicalKeyboardKey.backspace) &&
        controller!.text.length <= 0) {
      // onKey事件在textfield value change之前，所以这里需要延迟一下
      // 否则会导致在onEmptyDelete中设置controller.text之后，textfield处理删除键时，删掉新设置的text
      if (this.onEmptyDelete == null) return;
      Future.delayed(Duration.zero, () {
        this.onEmptyDelete!();
      });
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
  final OnKey? onEnter;
  final OnKey? selectNext;
  final OnKey? selectPrev;
  final Widget? inputPrefix;
  final Widget? inputSuffix;
  final OnKey? onEmptyDelete;
  final OnKey? onSpace;

  final TextEditingController? controller;

  InputBar({
    this.onEnter,
    this.controller,
    this.selectNext,
    this.selectPrev,
    this.inputPrefix,
    this.inputSuffix,
    this.onEmptyDelete,
    this.onSpace,
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
          onEmptyDelete: onEmptyDelete,
          onSpace: onSpace,
        ),
      ),
    ];
    if (inputPrefix != null) {
      widgets.insert(
        0,
        inputPrefix!,
      );
    }
    if (inputSuffix != null) {
      widgets.add(inputSuffix!);
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
