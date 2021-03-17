import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';

class ApplicationPlugin extends Plugin {
  ApplicationPlugin() {
    _getInstalledApps();
  }
  List<PluginListItem> apps;
  _getInstalledApps() async {
    final installedApps = await HotkeyShortcuts.getInstalledApps();
    final transformPinyinToKeywords = (String pinyin) {
      // 获取首字母
      final cc = pinyin.split(" ").map((e) => e[0]).join("");
      if (cc.length > 1) {
        return [cc.toLowerCase(), pinyin.toLowerCase()];
      }
      return [pinyin.toLowerCase()];
    };
    this.apps = installedApps
        .map((e) => PluginListItem(
              title: e['name'],
              subtitle: e['path'],
              keywords: transformPinyinToKeywords(e['pinyin']),
              icon:
                  'https://img.icons8.com/cute-clipart/128/000000/apple-app-store.png',
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
    print("application on Tap");
    HotkeyShortcuts.launchApp(item.subtitle);
  }
}
