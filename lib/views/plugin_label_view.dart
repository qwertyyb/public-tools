import 'package:flutter/material.dart';

import 'result_item_view.dart';

class PluginLabelView extends StatelessWidget {
  final String? icon;
  final String? title;
  final double? iconSize;

  PluginLabelView({this.icon, this.title, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ItemIconView(
          icon,
          size: iconSize ?? 30,
        ),
        Padding(padding: EdgeInsets.only(left: 6)),
        Text(title!)
      ],
    );
  }
}
