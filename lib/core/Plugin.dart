import 'package:flutter/material.dart';

import 'plugin_result_item.dart';

abstract class Plugin<T> {
  String label;

  String icon;

  List<String> keywords = [];

  void Function(bool) setLoading = (isLoading) {};

  void onQuery(
    String keyword,
    void Function(List<PluginListItem<T>> list) setResult,
  );

  void onTap(PluginListItem<T> item, {void Function() enterItem});

  void onEnter(PluginListItem item) {}

  void onSearch(
    String keyword,
    void Function(List<PluginListItem<T>> list) setResult,
  ) {
    setResult([]);
  }

  void onResultTap(PluginListItem<T> item) {}

  void onExit(PluginListItem item) {}

  void onResultSelect(PluginListItem<T> item,
      {void Function(Widget preview) setPreview}) {
    return setPreview(null);
  }
}
