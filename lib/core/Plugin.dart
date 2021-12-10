import 'package:flutter/material.dart';

import 'plugin_result_item.dart';

abstract class Plugin<T> {
  String label;

  String icon;

  List<String> keywords = [];

  void Function(bool) setLoading = (isLoading) {};

  void onQuery(
      String keyword, void Function(List<PluginListItem<T>> list) setResult);

  onTap(PluginListItem<T> item, {void Function() enterItem});

  void onEnter(PluginListItem item) {}

  void onSearch(
      String keyword, void Function(List<PluginListItem<T>> list) setResult) {
    setResult([]);
  }

  void onResultTap(PluginListItem<T> item) {}

  void onExit(PluginListItem item) {}

  Widget onResultSelect(PluginListItem<T> item) {
    return null;
  }
}
