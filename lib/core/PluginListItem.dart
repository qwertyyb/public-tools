import 'package:flutter/material.dart';

import 'Plugin.dart';

class PluginListItem<T> {
  String title;
  String subtitle;
  String icon;

  List<String> keywords;
  T id;

  PluginListItem(
      {this.title, this.subtitle, this.icon, this.id, this.keywords});
}

class PluginListResultItem {
  Plugin plugin;
  PluginListItem result;

  PluginListResultItem({this.plugin, this.result});

  onTap() {
    plugin.onTap(result);
  }

  Widget onSelect() {
    return plugin.onSelect(result);
  }
}
