import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/utils/logger.dart';
import 'package:public_tools/views/plugin_label_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotKeyView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HotKeyState();
  }
}

class HotKeyState extends State<HotKeyView> {
  Map<String, HotKey> _pluginsHotkey = {};
  bool _recordingHotKey = false;

  Future<Map<String, HotKey>> _getPluginsHotKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString('pluginsHotKey');
    if (savedValue == null || savedValue == '') return {};
    final json = jsonDecode(savedValue) as Map<String, dynamic>;
    return json.map<String, HotKey>(
        (key, value) => MapEntry(key, HotKey.fromJson(value)));
  }

  void refreshPluginsHotKey() async {
    final pluginsHotKey = await _getPluginsHotKey();
    setState(() {
      _pluginsHotkey = pluginsHotKey;
    });
  }

  void saveHotKey(String pluginId, HotKey hotkey) async {
    _pluginsHotkey[pluginId] = hotkey;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pluginsHotKey', jsonEncode(_pluginsHotkey));
    refreshPluginsHotKey();
    // setState(() {});
  }

  @override
  void initState() {
    this.refreshPluginsHotKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final plugins = PluginManager.instance.getPlugins().where((plugin) =>
        plugin.title != null &&
        plugin.title != '' &&
        plugin.id != null &&
        plugin.id != '');

    final rows = plugins.map<TableRow>((plugin) {
      final hotKey = _pluginsHotkey[plugin.id];
      return TableRow(
        decoration: BoxDecoration(color: Colors.grey[200]),
        children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Row(
                children: [
                  PluginLabelView(
                    icon: plugin.icon,
                    title: plugin.title,
                  ),
                  Spacer(),
                  _recordingHotKey
                      ? Container(
                          width: 100,
                          height: 30,
                          child: Center(
                            child: HotKeyRecorder(
                                initalHotKey: hotKey,
                                onHotKeyRecorded: (hotKey) {
                                  if (!_recordingHotKey) return;
                                  logger.i('hotKey: $hotKey');
                                  saveHotKey(plugin.id, hotKey);
                                  setState(() {
                                    _recordingHotKey = false;
                                  });
                                }),
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              _recordingHotKey = true;
                            });
                          },
                          child: hotKey == null
                              ? Text('未设置')
                              : HotKeyVirtualView(hotKey: hotKey))
                ],
              ))
        ],
      );
    });
    return Table(
      children: rows.toList(),
    );
  }
}
