import 'package:flutter/material.dart';
import 'package:public_tools/views/result_item_view.dart';

class PluginLabelView extends StatelessWidget {
  final String icon;
  final String title;

  PluginLabelView({this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PluginResultItemIconView(icon),
        Padding(padding: EdgeInsets.only(left: 6)),
        Text(title)
      ],
    );
  }
}
