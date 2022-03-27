import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/plugin.dart';
import '../../core/plugin_manager.dart';
import '../../views/plugin_label_view.dart';
import 'hotkey_recorder.dart';

class PluginSettingsView extends StatefulWidget {
  final Function? onHotKeyChange;

  PluginSettingsView({this.onHotKeyChange});

  @override
  State<StatefulWidget> createState() {
    return PluginSettingsState();
  }
}

const noExpandedPluginIds = const ['applicationLauncher'];

class PluginSettingsState extends State<PluginSettingsView> {
  Map<String, HotKey> _pluginsHotkey = {};
  Map<Plugin, bool> _expandedState = {};

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

  void saveHotKey(String pluginId, HotKey? hotkey) async {
    if (hotkey == null) {
      _pluginsHotkey.remove(pluginId);
    } else {
      _pluginsHotkey[pluginId] = hotkey;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pluginsHotKey', jsonEncode(_pluginsHotkey));
    refreshPluginsHotKey();
    widget.onHotKeyChange!();
    setState(() {});
  }

  @override
  void initState() {
    this.refreshPluginsHotKey();
    super.initState();
  }

  List<Widget> _getCommandsView(Plugin plugin) {
    final expanded = _expandedState[plugin] ?? false;
    if (!expanded) return [];
    return plugin.commands
        .map<Padding>(
          (command) => Padding(
            padding: EdgeInsets.only(left: 12, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                PluginLabelView(
                  icon: command.icon,
                  title: command.title,
                ),
                Spacer(),
                SizedBox(
                  width: 160,
                  child: HotKeyRecorderView(
                    disabled: plugin.commands.length != 1,
                    onHotKeyRecorded: (hotkey) => saveHotKey(plugin.id, hotkey),
                    hotKey: null,
                  ),
                )
              ],
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final plugins = PluginManager.instance.plugins
        .where((plugin) => plugin.title != '' && plugin.id != '');

    final rows = plugins.map<Column>((plugin) {
      final hotKey = _pluginsHotkey[plugin.id];
      final expanded = _expandedState[plugin] ?? false;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: !noExpandedPluginIds.contains(plugin.id) &&
                          plugin.commands.length > 1
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          icon: Icon(
                            expanded ? Icons.expand_less : Icons.chevron_right,
                          ),
                          onPressed: () {
                            setState(() {
                              _expandedState[plugin] = !expanded;
                            });
                          },
                        )
                      : null,
                ),
                PluginLabelView(
                  icon: plugin.icon,
                  title: plugin.title,
                ),
                Spacer(),
                SizedBox(
                  width: 160,
                  child: HotKeyRecorderView(
                    disabled: plugin.commands.length != 1,
                    onHotKeyRecorded: (hotkey) => saveHotKey(plugin.id, hotkey),
                    hotKey: hotKey,
                  ),
                )
              ],
            ),
          ),
          Column(children: _getCommandsView(plugin)),
        ],
      );
    });
    return ListView(
      children: rows.toList(),
    );
  }
}
