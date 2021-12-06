import 'package:flutter/material.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/views/PluginView.dart';

import 'PluginResultItemView.dart';

class PluginListView extends StatefulWidget {
  final List<PluginListResultItem> list;

  final int selectedIndex;

  final Function onTap;

  PluginListView({Key key, this.list, this.onTap, this.selectedIndex})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PluginListViewState();
}

class _PluginListViewState extends State<PluginListView> {
  Widget detailView;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 1,
        child: ListView.builder(
          itemBuilder: (pluginContext, itemIndex) {
            var resultItem = widget.list.elementAt(itemIndex);
            var pluginView = PluginResultItemView(
                item: resultItem.result,
                selected: itemIndex == widget.selectedIndex,
                onTap: resultItem.onTap,
                onSelect: (PluginListItem item, int index, list) {
                  setState(() {
                    detailView = resultItem.onSelect();
                  });
                });
            return pluginView;
          },
          itemCount: widget.list.length,
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
