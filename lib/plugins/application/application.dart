import 'dart:io';

import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';
import 'package:public_tools/pigeon/app.dart';

class ApplicationPlugin extends Plugin {
  ApplicationPlugin() {
    _getInstalledApps();
  }
  List<PluginListItem> apps;
  _getInstalledApps() async {
    final installedApps = await Service().getInstalledApplicationList();
    final transformPinyinToKeywords = (String pinyin) {
      // 获取首字母
      final cc = pinyin.split(" ").map((e) => e[0]).join("");
      if (cc.length > 1) {
        return [cc.toLowerCase(), pinyin.toLowerCase()];
      }
      return [pinyin.toLowerCase()];
    };
    this.apps = installedApps
        .map((app) => PluginListItem(
              title: app.name,
              subtitle: app.path,
              keywords: transformPinyinToKeywords(app.pinyin),
              icon: app.icon == ""
                  ? 'https://img.icons8.com/cute-clipart/128/000000/apple-app-store.png'
                  : app.icon,
            ))
        .toList();
  }

  onQuery(query, setList) {
    query = query.toLowerCase();
    final list = this.apps.where((element) {
      return element.keywords.any((keyword) => keyword.contains(query));
    }).toList();
    setList(list);
  }

  onTap(item) {
    Process.run("open", ["-a", item.subtitle]);
  }
}
