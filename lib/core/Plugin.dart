import 'package:flutter/widgets.dart';

class BaseListItem {
  String id;
  String subtitle;
  String title;
  String description;
  String icon;

  BaseListItem(
      {this.subtitle, this.title, this.description, this.icon, this.id});

  BaseListItem.fromJson(Map<String, dynamic> json) {
    subtitle = json['subtitle'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    id = json['id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subtitle'] = this.subtitle;
    data['title'] = this.title;
    data['description'] = this.description;
    data['icon'] = this.icon;
    data['id'] = this.id;
    return data;
  }
}

enum CommandMode {
  noView,
  listView,
}

class PluginCommand extends BaseListItem {
  List<String> keywords;
  CommandMode mode;

  PluginCommand(
      {String title,
      String subtitle,
      String icon,
      String description,
      String id,
      this.mode,
      this.keywords})
      : super(
            title: title,
            subtitle: subtitle,
            icon: icon,
            description: description,
            id: id);

  PluginCommand.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    keywords = json['keywords'].cast<String>();
    mode =
        (json['mode'] == 'noView' ? CommandMode.noView : CommandMode.listView);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['keywords'] = this.keywords;
    data['mode'] = this.mode == CommandMode.noView ? 'noView' : 'listView';
    return data;
  }
}

class SearchResult extends BaseListItem {
  SearchResult(
      {String title,
      String subtitle,
      String icon,
      String description,
      String id})
      : super(
            title: title,
            subtitle: subtitle,
            icon: icon,
            description: description,
            id: id);

  SearchResult.fromJson(json) : super.fromJson(json);
}

abstract class Plugin extends BaseListItem {
  List<PluginCommand> commands = [];

  Plugin(
      {String title,
      String subtitle,
      String description,
      String icon,
      this.commands})
      : super(
            subtitle: subtitle,
            title: title,
            description: description,
            icon: icon);

  Plugin.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['commands'] != null) {
      commands = [];
      json['commands'].forEach((v) {
        commands.add(new PluginCommand.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.commands != null) {
      data['commands'] = this.commands.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void onEnter(PluginCommand command);

  void onExit(PluginCommand command) {}

  Future<List<SearchResult>> onSearch(String search, PluginCommand command) {
    return Future.value([]);
  }

  Future<Widget> onResultSelected(SearchResult result) {
    return null;
  }

  void onResultTap(SearchResult result) {}
}

class PluginResult<T> {
  Plugin plugin;
  T value;

  PluginResult({this.plugin, this.value});
}
