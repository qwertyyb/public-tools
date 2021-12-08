import 'package:flutter/material.dart';

import 'plugin_result_item.dart';

abstract class Plugin<T> {
  String label;

  String icon;

  List<String> keywords = [];

  void onQuery(
      String keyword, void Function(List<PluginListItem<T>> list) setResult);

  onTap(PluginListItem<T> item);

  Widget onSelect(PluginListItem<T> item) {
    return null;
  }
}
