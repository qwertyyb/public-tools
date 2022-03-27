import 'dart:io';

import '../../core/plugin_command.dart';
import '../../core/plugin.dart';
import '../../pigeon/app.dart';
import '../../utils/logger.dart';

Future<List<PluginCommand>> _getInstalledApps() async {
  final installedApps = await Service().getInstalledApplicationList();
  final transformPinyinToKeywords = (String? pinyin) {
    // 获取首字母
    final cc = pinyin!.split(" ").map((e) => e[0]).join("");
    if (cc.length > 1) {
      return [cc.toLowerCase(), pinyin.toLowerCase()];
    }
    return [pinyin.toLowerCase()];
  };
  final apps = installedApps
      .map(
        (app) => PluginCommand(
          id: app!.name!,
          title: app.name!,
          subtitle: app.path!,
          description: app.path!,
          keywords: transformPinyinToKeywords(app.pinyin),
          icon: app.icon == ""
              ? 'https://img.icons8.com/cute-clipart/128/000000/apple-app-store.png'
              : app.icon!,
          mode: CommandMode.noView,
          onEnter: () async {
            logger.i('enter ${app.name}');
            Service().hideApp();
            Process.run("open", ["-a", app.name!]);
          },
        ),
      )
      .toList();
  applicationLauncherPlugin.commands = apps;
  return apps;
}

var applicationLauncherPlugin = Plugin(
  id: 'applicationLauncher',
  title: "应用程序",
  subtitle: "查看或打开已安装的应用程序",
  description: "查看或打开已安装的应用程序",
  icon: "https://img.icons8.com/cute-clipart/128/000000/apple-app-store.png",
  commands: [],
  onRegister: () {
    _getInstalledApps();
  },
);
