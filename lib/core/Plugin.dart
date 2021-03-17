import 'package:flutter/material.dart';

import 'PluginListItem.dart';

abstract class Plugin {
  String label;

  String icon;

  void onQuery(
      String keyword, void Function(List<PluginListItem> list) setResult);

  onTap(PluginListItem item);

  Widget onSelect(PluginListItem item, int index, List<PluginListItem> list) {
    return null;
  }
}
