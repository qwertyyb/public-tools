import 'dart:math';

import '../main.dart';
import '../pages/command_page.dart';
import '../plugins/application/application.dart';
import '../plugins/clipboard/clipboard.dart';
import '../plugins/command/command.dart';
import '../plugins/remote/remote.dart';
import '../plugins/settings/settings_plugin.dart';
import '../utils/logger.dart';
import 'plugin.dart';
import 'plugin_command.dart';

double _getMatchPoints(String keyword, String candidate) {
  final reg =
      new RegExp(keyword.split('').map<String>((e) => e + '.*').join(''));
  if (!reg.hasMatch(candidate)) return 0;
  return keyword.length.toDouble() / candidate.length.toDouble();
}

class PluginManager {
  // 工厂模式
  factory PluginManager() => _getInstance();
  static PluginManager get instance => _getInstance();
  static PluginManager? _instance;
  static PluginManager _getInstance() {
    if (_instance == null) {
      _instance = new PluginManager._internal();
    }
    return _instance!;
  }

  PluginManager._internal() {
    // 初始化
    _corePluginList.forEach((plugin) => register(plugin));
  }

  List<Plugin> _corePluginList = [
    remotePlugin,
    applicationLauncherPlugin,
    settingsPlugin,
    systemCommandPlugin,
    clipboardPlugin,
  ];

  List<Plugin> _pluginList = [];
  void register(Plugin plugin) {
    plugin.onRegister();
    _pluginList.add(plugin);
  }

  void updateResults(PluginCommand command, List<SearchResult>? results) {
    if (CommandPageState.current?.widget.command.id == command.id) {
      CommandPageState.current!.searchListKey.currentState!
          .updateResults(results!.map<PluginResult<SearchResult>>((result) {
        return PluginResult<SearchResult>(
          plugin: CommandPageState.current!.widget.plugin,
          value: result,
        );
      }).toList());
    }
  }

  List<PluginResult<PluginCommand>> searchCommands(String keyword) {
    var results = <PluginResult<PluginCommand>>[];
    _pluginList.forEach((plugin) {
      plugin.commands.forEach((command) {
        final points = command.keywords
            .map<double>((candidate) => _getMatchPoints(keyword, candidate));
        final maxPoint = points.reduce(max);
        if (maxPoint > 0) {
          results.add(PluginResult<PluginCommand>(
            plugin: plugin,
            value: command,
            point: maxPoint,
          ));
        }
        // return command.keywords.any((element) => reg.hasMatch(element));
      });
    });
    results.sort((prev, next) => ((next.point - prev.point) * 100000).round());
    return results;
  }

  void onCommand(PluginCommand command, Plugin plugin) {
    command.onEnter?.call();
    if (command.mode == CommandMode.listView) {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
      logger.i(navigatorKey.currentState!.canPop());
      navigatorKey.currentState!.pushNamed(
        CommandPage.routeName,
        arguments: CommandPageParams(
          plugin: plugin,
          command: command,
        ),
      );
    }
  }

  List<Plugin> get plugins => _pluginList;
}
