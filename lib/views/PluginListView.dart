
import 'package:flutter/material.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/views/PluginView.dart';

class PluginListView extends StatelessWidget {

  final Map<Plugin, List<PluginListItem>> list;

  final Function onTap;

  PluginListView({Key key, this.list, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (pluginContext, pluginIndex) {
        var plugin = list.keys.elementAt(pluginIndex);
        return PluginView(
          plugin: plugin,
          results: list[plugin],
          onTap: (PluginListItem item) => onTap(item, plugin),
        );
      },
      itemCount: list.keys.length,
    );
  }
}