import 'package:flutter/material.dart';

import 'plugin.dart';

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

  Map<String, dynamic> toJson() {
    final data = new Map<String, dynamic>();
    data["title"] = title;
    data["subtitle"] = subtitle;
    data["icon"] = icon;
    data["id"] = id;
    return data;
  }
}

class PluginListResultItem {
  Plugin plugin;
  PluginListItem result;

  PluginListResultItem({this.plugin, this.result});

  onTap({void Function() onEnterItem}) {
    plugin.onTap(result, enterItem: onEnterItem);
  }

  Widget onSelect() {
    return plugin.onResultSelect(result);
  }
}
