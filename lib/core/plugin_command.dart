import 'package:flutter/widgets.dart';

import 'base_list_item.dart';
import 'plugin_manager.dart';

enum CommandMode {
  noView,
  listView,
}

class SearchResult extends BaseListItem {
  SearchResult(
      {required String title,
      required String subtitle,
      String? icon,
      String? description,
      required String id})
      : super(
          title: title,
          subtitle: subtitle,
          icon: icon,
          description: description,
          id: id,
        );

  SearchResult.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}

class PluginCommand extends BaseListItem {
  List<String> keywords;
  CommandMode mode = CommandMode.listView;

  final Future<List<SearchResult>> Function(String keyword)? onSearch;

  final Future<Widget?> Function(SearchResult)? onResultPreview;

  final void Function(SearchResult)? onResultTap;

  void Function()? onEnter;

  void Function()? onExit;

  void updateResults(List<SearchResult>? results) {
    PluginManager.instance.updateResults(this, results);
  }

  PluginCommand(
      {required String title,
      required String subtitle,
      required String icon,
      String? description,
      required String id,
      required this.keywords,
      required this.mode,
      this.onEnter,
      this.onExit,
      this.onResultPreview,
      this.onResultTap,
      this.onSearch})
      : super(
          title: title,
          subtitle: subtitle,
          icon: icon,
          description: description,
          id: id,
        );

  PluginCommand.fromJsonAndFunction(
    Map<String, dynamic> json, {
    required this.onSearch,
    required this.onEnter,
    required this.onResultPreview,
    this.onResultTap,
    required this.onExit,
  })  : keywords = json['keywords'].cast<String>(),
        mode = (json['mode'] == 'noView'
            ? CommandMode.noView
            : CommandMode.listView),
        super.fromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['keywords'] = this.keywords;
    data['mode'] = this.mode == CommandMode.noView ? 'noView' : 'listView';
    return data;
  }
}
