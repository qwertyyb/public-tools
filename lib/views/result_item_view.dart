import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/base_list_item.dart';

class ItemIconView extends StatelessWidget {
  final String? icon;

  final double size = 30;

  ItemIconView(this.icon);

  @override
  Widget build(BuildContext context) {
    if (icon == null || icon == '') {
      return Icon(
        Icons.account_circle_rounded,
        size: size,
      );
    }
    return icon!.startsWith('http://') || icon!.startsWith('https://')
        ? CachedNetworkImage(
            imageUrl: icon!,
            placeholder: (context, string) => CircularProgressIndicator(),
            width: size,
            height: size,
          )
        : icon!.startsWith('base64:')
            ? Image.memory(
                base64Decode(icon!.substring('base64:'.length)),
                width: size,
                height: size,
              )
            : Image.file(File(icon!), width: size, height: size);
  }
}

class ResultItemView<T> extends StatelessWidget {
  final BaseListItem item;

  final bool? selected;

  final Function? onTap;

  ResultItemView({
    Key? key,
    required this.item,
    this.onTap,
    this.selected,
  }) : super(key: key);

  final FocusNode _focusNode = FocusNode(canRequestFocus: false);

  onKey(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: _focusNode,
        onKey: onKey,
        child: Container(
            height: 48,
            color: selected! ? Color.fromARGB(72, 78, 78, 78) : null,
            child: InkWell(
                onTap: onTap as void Function()?,
                focusNode: FocusNode(canRequestFocus: false),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ItemIconView(item.icon),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 3),
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (item.subtitle.isNotEmpty)
                                Text(
                                  item.subtitle,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.black38),
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
