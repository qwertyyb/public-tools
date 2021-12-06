import 'package:flutter/material.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/views/PluginResultItemView.dart';

class PluginView extends StatelessWidget {
  final Plugin plugin;
  final int pluginIndex;
  final int resultStartIndex;
  final int selectedIndex;
  final List<PluginListItem> results;

  final Function onTap;

  final Function onSelect;

  PluginView(
      {this.plugin,
      this.results,
      this.onTap,
      this.pluginIndex,
      this.selectedIndex,
      this.resultStartIndex,
      this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return PluginResultItemView(
              selected: resultStartIndex + i == selectedIndex,
              item: results[i],
              onTap: () {
                plugin.onTap(results[i]);
                onTap(results[i]);
              },
              onSelect: () {
                // plugin.onSelect(results[i], i, results);
                onSelect(results[i], i, results);
              });
        },
        itemCount: results.length,
      ),
    ]);
  }
}
