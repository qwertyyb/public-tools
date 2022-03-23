import 'dart:io';

import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/pigeon/app.dart';

class ApplicationPlugin extends Plugin {
  ApplicationPlugin() {
    _getInstalledApps();
  }
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
    this.commands = installedApps
        .map((app) => PluginCommand(
              title: app.name,
              subtitle: app.path,
              keywords: transformPinyinToKeywords(app.pinyin),
              icon: app.icon == ""
                  ? 'https://img.icons8.com/cute-clipart/128/000000/apple-app-store.png'
                  : app.icon,
            ))
        .toList();
  }

  @override
  void onEnter(PluginCommand command) {
    Service().hideApp();
    Process.run("open", ["-a", command.subtitle]);
  }
}
