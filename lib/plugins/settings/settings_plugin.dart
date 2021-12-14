import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_result_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Map<KeyModifier, List<LogicalKeyboardKey>> _knownLogicalKeys =
    <KeyModifier, List<LogicalKeyboardKey>>{
  KeyModifier.capsLock: [
    LogicalKeyboardKey.capsLock,
  ],
  KeyModifier.shift: [
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  ],
  KeyModifier.control: [
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
  ],
  KeyModifier.alt: [
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
  ],
  KeyModifier.meta: [
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  ],
  KeyModifier.fn: [
    LogicalKeyboardKey.fn,
  ],
};

String getHotkeyLabel(List<KeyModifier> modifiers, KeyCode keyCode) {
  String keyLabel;
  if (modifiers.length >= 0 && keyCode != null) {
    keyLabel = modifiers.map((element) => element.keyLabel).join('');
    keyLabel += keyCode.keyLabel;
  }
  return keyLabel;
}

class _HotkeyRecordButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HotkeyRecordState();
  }
}

class _HotkeyRecordState extends State<_HotkeyRecordButton> {
  List<KeyModifier> modifiers = [];
  KeyCode keyCode;

  FocusNode _focusNode;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    FocusManager.instance.addListener(() {
      print(FocusManager.instance.primaryFocus);
    });
    _focusNode = FocusNode(
      canRequestFocus: false,
      descendantsAreFocusable: false,
    );
    refreshStatus();
    super.initState();
  }

  void refreshStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var savedHotkey = prefs.getString("hotkey");
    if (savedHotkey == null) {
      final defaultHotkey = {
        'modifiers': [KeyModifier.meta.stringValue],
        'keyCode': KeyCode.space.stringValue
      };
      await prefs.setString('hotkey', jsonEncode(defaultHotkey));
    }
    savedHotkey = prefs.getString('hotkey');
    final json = jsonDecode(savedHotkey);
    final savedModifiers = List<String>.from(json["modifiers"]);
    final savedKeyCode = json["keyCode"];
    final modifiers = savedModifiers.map((e) => KeyModifierParser.parse(e));
    final keyCode = KeyCodeParser.parse(savedKeyCode);
    print('$modifiers, $keyCode');
    setState(() {
      this.modifiers = [KeyModifier.meta];
      this.keyCode = KeyCode.space;
      controller.text = getHotkeyLabel(this.modifiers, this.keyCode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onKey(RawKeyEvent event) {
    // @todo command + space时无法触发space事件,暂时无法使用此事件
    List<KeyModifier> modifiers = KeyModifier.values
        .where((element) => _knownLogicalKeys[element]
            .any((element) => event.isKeyPressed(element)))
        .toList();
    // @todo mac上按下shift键时，keyCode获取不到

    print("onKey: $modifiers, ${event.logicalKey}");
    if (_knownLogicalKeys.values
        .any((element) => element.contains(event.logicalKey))) {
      return;
    }
    final keyCode = KeyCodeParser.fromLogicalKey(event.logicalKey);
    print('$modifiers, $keyCode');
    if (modifiers.length > 0 && keyCode != null) {
      setState(() {
        this.modifiers = modifiers;
        this.keyCode = keyCode;
        controller.text = getHotkeyLabel(modifiers, keyCode);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _onKey,
      child: Container(
        color: Colors.black12,
        alignment: Alignment.center,
        width: 180,
        height: 32,
        child: TextField(
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.bottom,
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none),
          showCursor: false,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) => oldValue)
          ],
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SettingsPlugin extends Plugin {
  List<String> keywords = ['settings', 'preferences', '设置'];

  List<PluginListItem> commands = [
    PluginListItem(
      title: '设置',
      subtitle: 'Public设置',
      icon: null,
    )
  ];

  onQuery(query, setResult) {
    var match = keywords.where((element) => element.contains(query)).length > 0;
    if (match) {
      setResult(commands);
    } else {
      setResult([]);
    }
  }

  onTap(item, {enterItem}) {
    // @todo 跳转到设置页面
    enterItem();
  }

  @override
  void onEnter(PluginListItem item) {
    super.onEnter(item);
  }

  @override
  void onSearch(
      String keyword, void Function(List<PluginListItem> list) setResult) {
    setResult(
        [PluginListItem<String>(title: "基础", subtitle: '基础设置', id: 'basic')]);
  }

  @override
  void onResultSelect(PluginListItem item, {setPreview}) {
    if (item.id == 'basic') {
      setPreview(Padding(
        padding: EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text('快捷键'),
              ),
              _HotkeyRecordButton()
            ],
          ),
        ),
      ));
    }
    return null;
  }
}
