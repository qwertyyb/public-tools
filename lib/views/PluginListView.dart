import 'package:flutter/material.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/views/PluginView.dart';

class PluginListView extends StatefulWidget {
  final Map<Plugin, List<PluginListItem>> list;

  final Function onTap;

  PluginListView({Key key, this.list, this.onTap}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginListViewState();
}

class _PluginListViewState extends State<PluginListView> {
  Widget detailView;

  @override
  Widget build(BuildContext context) {
    var startIndex = -1;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 1,
        child: ListView.builder(
          itemBuilder: (pluginContext, pluginIndex) {
            var plugin = widget.list.keys.elementAt(pluginIndex);
            var pluginView = PluginView(
                plugin: plugin,
                results: widget.list[plugin],
                pluginIndex: pluginIndex,
                resultStartIndex: startIndex + 1,
                onTap: (PluginListItem item) => widget.onTap(item, plugin),
                onSelect: (PluginListItem item, int index, list) {
                  setState(() {
                    detailView = plugin.onSelect(item, index, list);
                  });
                });
            startIndex += widget.list[plugin].length;
            return pluginView;
          },
          itemCount: widget.list.keys.length,
        ),
      ),
      if (detailView != null)
        Expanded(
          flex: 1,
          child: Container(
              height: double.infinity,
              padding: EdgeInsets.all(8),
              color: Colors.grey[300],
              child: Container(
                child: detailView,
              )),
        )
    ]);
  }
}
