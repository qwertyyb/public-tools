import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hotkey_recorder.dart';

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

  @override
  void initState() {
    this._refreshHotKey();
    super.initState();
  }

  void _refreshHotKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString('mainHotKey');
    if (savedValue == null || savedValue == '') return;
    final json = jsonDecode(savedValue) as Map<String, dynamic>?;
    setState(() {
      _hotKey = HotKey.fromJson(json!);
    });
  }

  void _saveHotKey(HotKey? _hotKey) async {
    if (_hotKey == null) return;
    setState(() {
      this._hotKey = _hotKey;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('mainHotKey', jsonEncode(_hotKey));
    widget.onHotKeyChange!();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Text('快捷键'),
              ),
              SizedBox(
                width: 160,
                child: HotKeyRecorderView(
                  onHotKeyRecorded: _saveHotKey,
                  hotKey: _hotKey,
                  canRemove: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
