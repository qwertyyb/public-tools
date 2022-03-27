import 'dart:io';

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';

enum Command { lock, sleep, shutdown, restart }

void _commandHandler(String oascript) {
  Process.run('osascript', ["-e", oascript]);
}

List<PluginCommand> _commands = [
  PluginCommand(
    id: 'lock',
    title: "锁屏",
    subtitle: "锁定你的电脑",
    keywords: ['lock', 'lockscreen', 'sp'],
    icon: 'https://img.icons8.com/fluent/96/000000/touch-id.png',
    mode: CommandMode.noView,
    onEnter: () => _commandHandler(
      'tell application "System Events" to keystroke "q" using {control down, command down}',
    ),
  ),
  PluginCommand(
    id: 'sleep',
    title: '睡眠',
    subtitle: '让你的电脑睡眠',
    keywords: ['sleep', 'sm'],
    icon: 'https://img.icons8.com/fluent/96/000000/sleep-mode.png',
    mode: CommandMode.noView,
    onEnter: () => _commandHandler("""
          tell application "System Events"
            start (sleep)
          end tell
        """),
  ),
  PluginCommand(
    id: 'shutdown',
    title: '关机',
    subtitle: '关闭你的电脑',
    keywords: ['shutdown', 'gj'],
    icon: 'https://img.icons8.com/fluent/96/000000/shutdown.png',
    mode: CommandMode.noView,
    onEnter: () => _commandHandler("""
            tell application "System Events"
              start (shut down)
            end tell
        """),
  ),
  PluginCommand(
    id: 'restart',
    title: '重启',
    subtitle: '重新启动你的电脑',
    keywords: ['restart', 'cq'],
    icon: 'https://img.icons8.com/cute-clipart/128/000000/restart.png',
    mode: CommandMode.noView,
    onEnter: () => _commandHandler("""
            tell application "System Events"
              start (restart)
            end tell
        """),
  )
];

final systemCommandPlugin = Plugin(
  id: 'system-command',
  title: '系统命令',
  subtitle: '执行系统命令',
  description: '执行系统命令',
  icon: 'https://img.icons8.com/fluent/96/000000/shutdown.png',
  commands: _commands,
);
