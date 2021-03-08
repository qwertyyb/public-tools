


import 'package:flutter/material.dart';
import 'package:ypaste_flutter/core/PluginListItem.dart';

class PluginListItemView extends StatelessWidget {

  final PluginListItem item;

  final Function onTap;

  PluginListItemView({ this.item, this.onTap });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: SizedBox.expand(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off_outlined, size: 30),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          )
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black38
                        ),
                      )
                    ],
                  )
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}