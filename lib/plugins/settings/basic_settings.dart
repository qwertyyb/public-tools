import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hotkey_recorder.dart';
import 'setting_key.dart';

class BasicSettingsView extends StatefulWidget {
  final void Function()? onHotKeyChange;

  BasicSettingsView({this.onHotKeyChange});

  @override
  State<StatefulWidget> createState() {
    return _BasicSettingsState();
  }
}

class _BasicSettingsState extends State<BasicSettingsView> {
  HotKey? _hotKey;
  int _exitCommandDuration = 10;

  @override
  void initState() {
    this._refreshStatus();
    super.initState();
  }

  void _refreshStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(SettingKey.mainHotKey);
    if (savedValue == null || savedValue == '') return;
    final json = jsonDecode(savedValue) as Map<String, dynamic>?;
    setState(() {
      _hotKey = HotKey.fromJson(json!);
      _exitCommandDuration = prefs.getInt(SettingKey.exitCommandDuration) ?? 10;
    });
  }

  void _saveHotKey(HotKey? _hotKey) async {
    if (_hotKey == null) return;
    setState(() {
      this._hotKey = _hotKey;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(SettingKey.mainHotKey, jsonEncode(_hotKey));
    widget.onHotKeyChange!();
  }

  void _saveExitCommandDuration(int? seconds) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(SettingKey.exitCommandDuration, seconds ?? 10);
    setState(() {
      this._exitCommandDuration = seconds ?? 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64.0),
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    '快捷键',
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: SizedBox(
                    width: 160,
                    child: HotKeyRecorderView(
                      onHotKeyRecorded: _saveHotKey,
                      hotKey: _hotKey,
                      canRemove: false,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    '自动到顶层搜索',
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: DropdownButton(
                    value: _exitCommandDuration,
                    items: <int>[0, 10, 30, 60, 90, -1]
                        .map<DropdownMenuItem<int>>(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              '${value == 0 ? '立刻' : value == -1 ? '永不' : '$value秒后'}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _saveExitCommandDuration,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
