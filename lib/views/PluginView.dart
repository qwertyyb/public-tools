import 'package:flutter/material.dart';
import 'package:ypaste_flutter/core/Plugin.dart';
import 'package:ypaste_flutter/core/PluginListItem.dart';
import 'package:ypaste_flutter/views/PluginListItemView.dart';

class PluginView extends StatelessWidget {
  final Plugin plugin;
  final List<PluginListItem> results;

  PluginView({this.plugin, this.results});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return PluginListItemView(
            item: results[i],
            onTap: () { plugin.onTap(results[i]); },
          );
        },
        itemCount: results.length,
      ),
    ]);
  }
}
