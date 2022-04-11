import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';
import '../../core/plugin_manager.dart';
import '../../utils/logger.dart';
import '../../views/plugin_label_view.dart';
import 'hotkey_recorder.dart';
import 'setting_key.dart';

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
  Map<String, Map<String, HotKey>> _pluginsHotkey = {};
  Map<Plugin, bool> _expandedState = {};

  Future<Map<String, Map<String, HotKey>>> _getPluginsHotKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedValue = prefs.getString(SettingKey.pluginsCommandsHotKey);
    if (savedValue == null || savedValue == '') return {};
    final json = jsonDecode(savedValue) as Map<String, dynamic>;
    return json.map<String, Map<String, HotKey>>(
      (key, value) => MapEntry(
        key,
        (value as Map<String, dynamic>).map<String, HotKey>(
          (commandId, commandHotKey) => MapEntry(
            commandId,
            HotKey.fromJson(commandHotKey),
          ),
        ),
      ),
    );
  }

  void refreshPluginsHotKey() async {
    final pluginsHotKey = await _getPluginsHotKey();
    setState(() {
      _pluginsHotkey = pluginsHotKey;
    });
  }

  void saveHotKey(
    String pluginId,
    PluginCommand command,
    HotKey? hotKey,
  ) async {
    logger.i('saveHotKey: $pluginId, $command, $hotKey');
    if (hotKey == null) {
      _pluginsHotkey.remove(pluginId);
    } else {
      _pluginsHotkey[pluginId] = {
        command.id: hotKey,
      };
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      SettingKey.pluginsCommandsHotKey,
      jsonEncode(_pluginsHotkey),
    );
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
            padding: EdgeInsets.only(left: 12, right: 6, top: 2, bottom: 2),
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
                  iconSize: 20,
                ),
                Spacer(),
                SizedBox(
                  width: 160,
                  child: HotKeyRecorderView(
                    disabled: false,
                    onHotKeyRecorded: (hotkey) =>
                        saveHotKey(plugin.id, command, hotkey),
                    hotKey: (_pluginsHotkey[plugin.id] ?? const {})[command.id],
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
    final plugins = PluginManager.instance.plugins.where((plugin) =>
        plugin.title != '' && plugin.id != '' && plugin.commands.isNotEmpty);

    final rows = plugins.map<Column>((plugin) {
      final commandsHotKey = _pluginsHotkey[plugin.id];
      final expanded = _expandedState[plugin] ?? false;
      // logger.i(
      // '${plugin.id}, ${plugin.commands.first.id}, ${},${(commandsHotKey ?? const {})[plugin.commands.first]}');
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
                  iconSize: 20,
                ),
                Spacer(),
                SizedBox(
                  width: 160,
                  child: HotKeyRecorderView(
                    disabled: plugin.commands.length != 1,
                    onHotKeyRecorded: (hotkey) =>
                        saveHotKey(plugin.id, plugin.commands.first, hotkey),
                    hotKey:
                        (commandsHotKey ?? const {})[plugin.commands.first.id],
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
