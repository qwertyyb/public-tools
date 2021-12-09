import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PluginLabelView extends StatelessWidget {
  final String icon;
  final String title;

  PluginLabelView({this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CachedNetworkImage(imageUrl: icon, width: 32, height: 32),
        Padding(padding: EdgeInsets.only(left: 6)),
        Text(title)
      ],
    );
  }
}
