import 'dart:io';

import 'package:public_tools/core/plugin.dart';

enum Command { lock, sleep, shutdown, restart }

class SystemCommandPlugin extends Plugin {
  List<PluginCommand> commands = [
    PluginCommand(
        title: "锁屏",
        subtitle: "锁定你的电脑",
        description: """
            tell application "System Events" to keystroke "q" using {control down, command down}
        """,
        keywords: ['lock', 'lockscreen', 'sp'],
        icon: 'https://img.icons8.com/fluent/96/000000/touch-id.png'),
    PluginCommand(
        title: '睡眠',
        subtitle: '让你的电脑睡眠',
        keywords: ['sleep', 'sm'],
        icon: 'https://img.icons8.com/fluent/96/000000/sleep-mode.png',
        description: """
          tell application "System Events"
            start (sleep)
          end tell
        """),
    PluginCommand(
        title: '关机',
        subtitle: '关闭你的电脑',
        keywords: ['shutdown', 'gj'],
        description: """
            tell application "System Events"
              start (shut down)
            end tell
        """,
        icon: 'https://img.icons8.com/fluent/96/000000/shutdown.png'),
    PluginCommand(
        title: '重启',
        subtitle: '重新启动你的电脑',
        keywords: ['restart', 'cq'],
        description: """
            tell application "System Events"
              start (restart)
            end tell
        """,
        icon: 'https://img.icons8.com/cute-clipart/128/000000/restart.png')
  ];

  @override
  void onEnter(PluginCommand command) {
    Process.run('osascript', ["-e", command.description]);
  }
}
