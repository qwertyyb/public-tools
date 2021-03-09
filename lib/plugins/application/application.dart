import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:ypaste_flutter/core/Plugin.dart';
import 'package:ypaste_flutter/core/PluginListItem.dart';

class ApplicationPlugin extends Plugin {
  ApplicationPlugin() {
    _getInstalledApps();
  }
  List<PluginListItem> apps;
  _getInstalledApps() async {
    final installedApps = await HotkeyShortcuts.getInstalledApps();
    this.apps = installedApps
      .map((e) => PluginListItem(title: e['name'], subtitle: e['path']))
      .toList();
  }
  onInput(query, setList) {
    final keyword = query.toLowerCase();
    final list = this.apps.where((element) => element.title.toLowerCase().contains(keyword)).toList();
    setList(list);
  }
  onTap(item) {}
}