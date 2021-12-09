import 'dart:io';

import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_result_item.dart';

enum Command { lock, sleep, shutdown, restart }

class CommandPlugin extends Plugin<Command> {
  Map<Command, String> _commands = {
    Command.lock: """
        tell application "System Events" to keystroke "q" using {control down, command down}
    """,
    Command.sleep: """
        tell application "System Events"
          start (sleep)
        end tell
    """,
    Command.shutdown: """
        tell application "System Events"
          start (shut down)
        end tell
    """,
    Command.restart: """
        tell application "System Events"
          start (restart)
        end tell
    """,
  };

  List<PluginListItem<Command>> _commandList = [
    PluginListItem(
        id: Command.lock,
        title: "锁屏",
        subtitle: "锁定你的电脑",
        keywords: ['lock', 'lockscreen', 'sp'],
        icon: 'https://img.icons8.com/fluent/96/000000/touch-id.png'),
    PluginListItem(
        id: Command.sleep,
        title: '睡眠',
        subtitle: '让你的电脑睡眠',
        keywords: ['sleep', 'sm'],
        icon: 'https://img.icons8.com/fluent/96/000000/sleep-mode.png'),
    PluginListItem(
        id: Command.shutdown,
        title: '关机',
        subtitle: '关闭你的电脑',
        keywords: ['shutdown', 'gj'],
        icon: 'https://img.icons8.com/fluent/96/000000/shutdown.png'),
    PluginListItem(
      id: Command.restart,
      title: '重启',
      subtitle: '重新启动你的电脑',
      keywords: ['restart', 'cq'],
      icon: 'https://img.icons8.com/cute-clipart/128/000000/restart.png',
    )
  ];

  onQuery(query, setResult) {
    final list = _commandList
        .where((command) =>
            command.keywords.any((keyword) => keyword.startsWith(query)))
        .toList();
    setResult(list);
  }

  onTap(PluginListItem<Command> item, {enterItem}) {
    Process.run('osascript', ["-e", _commands[item.id]]);
  }
}
