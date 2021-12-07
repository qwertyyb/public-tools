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

  PluginListItem.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    title = json['title'];
    subtitle = json['subtitle'];
    id = json['id'];
  }
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
