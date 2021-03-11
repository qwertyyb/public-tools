
import 'package:flutter/material.dart';
import 'package:ypaste_flutter/core/Plugin.dart';
import 'package:ypaste_flutter/core/PluginListItem.dart';
import 'package:ypaste_flutter/views/PluginView.dart';

class PluginListView extends StatelessWidget {

  final Map<Plugin, List<PluginListItem>> list;

  PluginListView({Key key, this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (pluginContext, pluginIndex) {
        var plugin = list.keys.elementAt(pluginIndex);
        return PluginView(
          plugin: plugin,
          results: list[plugin],
        );
      },
      itemCount: list.keys.length,
    );
  }
}