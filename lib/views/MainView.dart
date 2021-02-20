import 'package:flutter/material.dart';
import 'package:ypaste_flutter/core/Plugin.dart';
import 'package:ypaste_flutter/core/PluginManager.dart';
import 'package:ypaste_flutter/models/CommonListItem.dart';
import 'package:ypaste_flutter/views/PluginView.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Map<Plugin, List<CommonListItem>> list = Map<Plugin, List<CommonListItem>>();

  void _onKeywordChange(String keyword) {
    PluginManager.instance.handleInput(keyword, this._setPluginResult);
  }

  void _setPluginResult(Plugin plugin, List<CommonListItem> result) {
    setState(() {
      list[plugin] = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
      itemBuilder: (pluginContext, pluginIndex) {
        var plugin = list.keys.elementAt(pluginIndex);
        return PluginView(
          plugin: plugin,
          results: list[plugin],
        );
      },
      itemCount: list.keys.length,
    );
    return Column(
      children: [
        TextField(
          onChanged: this._onKeywordChange,
        ),
        Expanded(
          child: listView,
        )
      ],
    );
  }
}
