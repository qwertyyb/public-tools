import 'package:flutter/material.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/views/PluginListItemView.dart';

class PluginView extends StatelessWidget {
  final Plugin plugin;
  final List<PluginListItem> results;

  final Function onTap;

  PluginView({this.plugin, this.results, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return PluginListItemView(
            item: results[i],
            onTap: () {
              plugin.onTap(results[i]);
              onTap(results[i]);
            },
          );
        },
        itemCount: results.length,
      ),
    ]);
  }
}
