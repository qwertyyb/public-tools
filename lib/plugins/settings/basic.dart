import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/plugins/settings/utils.dart';
import 'package:public_tools/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasicView extends StatelessWidget {
  final void Function() onHotkeyChange;

  BasicView({this.onHotkeyChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text('快捷键'),
            ),
            _HotkeyRecordButton(
              onHotkeyChange: onHotkeyChange,
            )
          ],
        ),
      ),
    );
  }
}

String getHotkeyLabel(List<KeyModifier> modifiers, KeyCode keyCode) {
  String keyLabel;
  if (modifiers.length >= 0 && keyCode != null) {
    keyLabel = modifiers.map((element) => element.keyLabel).join('');
    keyLabel += keyCode.keyLabel;
  }
  return keyLabel;
}

class _HotkeyRecordButton extends StatefulWidget {
  final void Function() onHotkeyChange;

  _HotkeyRecordButton({this.onHotkeyChange});

  @override
  State<StatefulWidget> createState() {
    return _HotkeyRecordState();
  }
}

class _HotkeyRecordState extends State<_HotkeyRecordButton> {
  List<KeyModifier> modifiers = [];
  KeyCode keyCode;

  FocusNode _focusNode;
  TextEditingController _controller = TextEditingController();
  String _placeholder = '';

  @override
  void initState() {
    _focusNode = FocusNode(
      canRequestFocus: false,
      descendantsAreFocusable: false,
    );
    refreshStatus();
    super.initState();
  }

  void refreshStatus() async {
    final hotkey = await getHotkeyFromPrefs();
    final label = getHotkeyLabel(hotkey.modifiers, hotkey.keyCode);
    _controller.text = label;
    setState(() {
      _placeholder = label;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyUpEvent) return KeyEventResult.handled;
    final modifiers = event.data.modifiersPressed.keys
        .map<KeyModifier>((e) => KeyModifierParser.fromModifierKey(e))
        .toList();

    // 当前按下的键就是修饰键，直接返回
    if (KeyModifier.values
        .any((element) => element.logicalKeys.contains(event.logicalKey))) {
      return KeyEventResult.handled;
    }

    final keyCode = KeyCodeParser.fromLogicalKey(event.logicalKey);

    if (modifiers.length > 0 && keyCode != null) {
      this._focusNode.unfocus();
      SharedPreferences.getInstance().then((prefs) {
        final hotkey = {
          'modifiers':
              modifiers.map((modifier) => modifier.stringValue).toList(),
          'keyCode': keyCode.stringValue
        };
        prefs.setString('hotkey', jsonEncode(hotkey)).then((value) {
          widget.onHotkeyChange();
        });
        refreshStatus();
      });
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKey: _onKey,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _controller.text = '';
        } else {
          refreshStatus();
        }
      },
      child: Container(
        color: Colors.black12,
        alignment: Alignment.center,
        width: 180,
        height: 32,
        child: TextField(
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.bottom,
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _placeholder,
            contentPadding: EdgeInsets.all(10),
          ),
          showCursor: false,
          inputFormatters: [
            // 禁止输入
            TextInputFormatter.withFunction((oldValue, newValue) => oldValue)
          ],
        ),
      ),
    );
  }
}
