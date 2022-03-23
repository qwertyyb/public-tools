import 'package:flutter/widgets.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/plugins/application/application.dart';
import 'package:public_tools/plugins/clipboard/clipboard.dart';
import 'package:public_tools/plugins/command/command.dart';
import 'package:public_tools/plugins/remote/remote.dart';
import 'package:public_tools/plugins/settings/settings_plugin.dart';
import 'package:public_tools/utils/logger.dart';

class PageState<T> extends ChangeNotifier {
  String keyword = '';
  List<T> list = [];
  int selectedIndex = 0;

  update(Function updater) {
    updater();
    notifyListeners();
  }
}

class MainPageState extends PageState<PluginResult<PluginCommand>> {}

class CommandPageState extends PageState<SearchResult> {
  Plugin plugin;
}

class MainState extends ChangeNotifier {
  bool isSearchingCommand = true;
  String topKeyword = '';
  List<PluginResult<PluginCommand>> commands = [];
  int commandSelectedIndex = 0;
  PluginResult<PluginCommand> selectedCommand;

  String keywordInCommand = '';
  List<PluginResult<SearchResult>> searchResults = [];
  int resultSelectedIndex = 0;
  PluginResult<SearchResult> selectedResult;

  Widget resultPreview;

  String get keyword {
    return isSearchingCommand ? topKeyword : keywordInCommand;
  }

  List<PluginResult<BaseListItem>> get list {
    return isSearchingCommand ? commands : searchResults;
  }

  int get selectedIndex {
    return isSearchingCommand ? commandSelectedIndex : resultSelectedIndex;
  }

  set selectedIndex(int value) {
    if (isSearchingCommand) {
      commandSelectedIndex = value;
    } else {
      resultSelectedIndex = value;
    }
    _updatePreview();
    notifyListeners();
  }

  PluginResult<BaseListItem> get selected {
    return isSearchingCommand ? selectedResult : selectedCommand;
  }

  void _updatePreview() async {
    if (resultPreview == null && (selected == null || isSearchingCommand)) {
      return;
    }
    if (selectedResult != null && !isSearchingCommand) {
      resultPreview =
          await selectedResult.plugin.onResultSelected(selectedResult.value);
    } else {
      resultPreview = null;
    }
    notifyListeners();
  }

  update(Function updater) {
    updater();
    _updatePreview();
    notifyListeners();
  }
}

class PluginManager {
  // 工厂模式
  factory PluginManager() => _getInstance();
  static PluginManager get instance => _getInstance();
  static PluginManager _instance;
  static PluginManager _getInstance() {
    if (_instance == null) {
      _instance = new PluginManager._internal();
    }
    return _instance;
  }

  PluginManager._internal() {
    // 初始化
    _corePluginList.forEach((plugin) => register(plugin));
  }

  MainState state = MainState();

  List<Plugin> _corePluginList = [
    SettingsPlugin(),
    SystemCommandPlugin(),
    ClipboardPlugin(),
    ApplicationPlugin(),
    RemotePlugin(),
  ];

  List<Plugin> _pluginList = [];
  void register(Plugin plugin) {
    _pluginList.add(plugin);
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
    state.update(() {
      state.topKeyword = keyword;
      state.commands = commands;
      state.commandSelectedIndex = 0;
    });
    return commands;
  }

  void _searchInCommand(String keyword) async {
    assert(state.isSearchingCommand == false);
    assert(state.selectedCommand != null);

    final plugin = state.selectedCommand.plugin;
    final results = await plugin.onSearch(keyword, state.selectedCommand.value);
    state.update(() {
      state.keywordInCommand = keyword;
      state.resultSelectedIndex = 0;
      state.searchResults = results
          .map((result) =>
              PluginResult<SearchResult>(plugin: plugin, value: result))
          .toList();
      state.selectedResult =
          state.searchResults.isNotEmpty ? state.searchResults[0] : null;
    });
  }

  void onSearch(String keyword) {
    logger.i('[onSearch] search: $keyword');

    if (state.isSearchingCommand) {
      this.searchCommands(keyword);
      return;
    }
    this._searchInCommand(keyword);
  }

  void _onEnter() {
    logger.i('PluginManager._onEnter');
    assert(state.isSearchingCommand);
    assert(state.selectedCommand == null);
    assert(state.searchResults.isEmpty);

    final selectedCommand = state.commands[state.commandSelectedIndex];
    selectedCommand.plugin.onEnter(selectedCommand.value);
    if (selectedCommand.value.mode == CommandMode.listView) {
      state.update(() {
        state.isSearchingCommand = false;
        state.selectedCommand = selectedCommand;
      });
      this._searchInCommand('');
    }
  }

  void onCommand(PluginResult<PluginCommand> command) {
    command.plugin.onEnter(command.value);
    if (command.value.mode == CommandMode.listView) {
      state.update(() {
        state.isSearchingCommand = false;
        state.selectedCommand = command;
      });
      this._searchInCommand('');
    }
  }

  void _onResultTap() {
    assert(state.isSearchingCommand == false);
    assert(state.selectedCommand != null);
    assert(state.searchResults.isNotEmpty);
    assert(state.selectedResult != null);

    final result = state.selectedResult;
    result.plugin.onResultTap(result.value);
  }

  void onTap() {
    if (state.isSearchingCommand) {
      this._onEnter();
      return;
    }
    this._onResultTap();
  }

  void onResultSelected(PluginResult<SearchResult> result) async {
    assert(state.isSearchingCommand == false);
    assert(state.selectedCommand != null);
    assert(state.searchResults.isNotEmpty == false);

    final preview = await result.plugin.onResultSelected(result.value);
    state.update(() {
      state.resultPreview = preview;
    });
  }

  void onExit() {
    if (state.isSearchingCommand) {
      return;
    }

    state.selectedCommand.plugin.onExit(state.selectedCommand.value);
    state.update(() {
      state.searchResults.clear();
      state.resultPreview = null;
      state.isSearchingCommand = true;
      state.selectedCommand = null;
      state.selectedResult = null;
    });
  }

  // ui相关
  void selectNext() {
    final list =
        state.isSearchingCommand ? state.commands : state.searchResults;
    final nextIndex = (state.selectedIndex + 1) % list.length;
    state.selectedIndex = nextIndex;
    if (!state.isSearchingCommand) {
      state.selectedResult = list[nextIndex];
    }
  }

  void selectPrevious() {
    final list =
        state.isSearchingCommand ? state.commands : state.searchResults;
    final nextIndex = (state.selectedIndex - 1 + list.length) % list.length;
    state.selectedIndex = nextIndex;
    if (!state.isSearchingCommand) {
      state.selectedResult = list[nextIndex];
    }
  }

  //
  List<Plugin> getPlugins() {
    return _pluginList;
  }
}
