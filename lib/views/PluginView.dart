import 'package:flutter/material.dart';
import 'package:ypaste_flutter/core/Plugin.dart';
import 'package:ypaste_flutter/models/CommonListItem.dart';

class PluginView extends StatelessWidget {
  final Plugin plugin;
  final List<CommonListItem> results;

  PluginView({this.plugin, this.results});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: Colors.blueGrey,
        child: Row(
          children: [
            Image.network(plugin.icon, width: 30, height: 30),
            Text(
              plugin.label,
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            Spacer(),
            Text(results.length.toString() + '项',
                style: TextStyle(color: Colors.white60, fontSize: 12))
          ],
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.history_toggle_off_outlined, size: 30)],
            ),
            title: Text(results[i].title,
                maxLines: 1, style: TextStyle(fontWeight: FontWeight.w400)),
            subtitle: Text(
              results[i].subtitle,
              maxLines: 1,
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              results[i].onTap(results[i], i, results);
            },
          );
        },
        itemCount: results.length,
      ),
    ]);
  }
}
