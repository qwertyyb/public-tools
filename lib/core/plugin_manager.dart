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
    applicationLauncherPlugin,
    settingsPlugin,
    systemCommandPlugin,
    clipboardPlugin,
    remotePlugin,
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
    final commands = _pluginList
        .map((plugin) {
          return plugin.commands
              .where((command) => command.keywords
                  .any((element) => element.startsWith(keyword)))
              .map((command) =>
                  PluginResult<PluginCommand>(plugin: plugin, value: command));
        })
        .expand((element) => element)
        .toList();
    return commands;
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
