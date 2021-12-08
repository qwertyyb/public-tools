import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:public_tools/core/Plugin.dart';

class PluginLabelView extends StatelessWidget {
  // final Plugin plugin;

  // PluginLabelView({this.plugin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            children: [
              CachedNetworkImage(
                  imageUrl:
                      "https://vfiles.gtimg.cn/vupload/20211129/2da75c1638159214694.png",
                  width: 24,
                  height: 24),
              Padding(padding: EdgeInsets.only(left: 6)),
              Text("好好学习")
            ],
          ),
        ),
        IgnorePointer(child: Spacer())
      ],
    );
  }
}
