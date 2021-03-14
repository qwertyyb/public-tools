import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';

class CommandPlugin extends Plugin {
  List<PluginListItem> _commandList = [
    PluginListItem(
        id: 'lock',
        title: "锁屏",
        subtitle: "锁定你的电脑",
        keywords: ['lock', 'lockscreen', 'sp'],
        icon: 'https://img.icons8.com/fluent/96/000000/touch-id.png'),
    PluginListItem(
        id: 'sleep',
        title: '睡眠',
        subtitle: '让你的电脑睡眠',
        keywords: ['sleep', 'sm'],
        icon: 'https://img.icons8.com/fluent/96/000000/sleep-mode.png'),
    PluginListItem(
        id: 'shutdown',
        title: '关机',
        subtitle: '关闭你的电脑',
        keywords: ['shutdown', 'gj'],
        icon: 'https://img.icons8.com/fluent/96/000000/shutdown.png'),
    PluginListItem(
      id: 'restart',
      title: '重启',
      subtitle: '重新启动你的电脑',
      keywords: ['restart', 'cq'],
      icon: 'https://img.icons8.com/cute-clipart/128/000000/restart.png',
    )
  ];

  onInput(query, setResult) {
    print("query");
    final list = _commandList
        .where((command) =>
            command.keywords.any((keyword) => keyword.startsWith(query)))
        .toList();
    setResult(list);
  }

  onTap(item) {
    HotkeyShortcuts.execCommand(item.id);
  }
}
