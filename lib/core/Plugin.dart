import 'package:flutter/material.dart';

import 'plugin_result_item.dart';

abstract class Plugin<T> {
  String label;

  String icon;

  List<String> keywords = [];

  void Function(bool) setLoading = (isLoading) {};

  void onEnter(PluginListItem item) {}

  void onExit(PluginListItem item) {}

  void onQuery(
      String keyword, void Function(List<PluginListItem<T>> list) setResult);

  onTap(PluginListItem<T> item, {void Function() enterItem});

  Widget onSelect(PluginListItem<T> item) {
    return null;
  }
}
