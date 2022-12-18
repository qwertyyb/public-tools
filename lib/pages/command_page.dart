import 'package:flutter/material.dart';

import '../core/plugin.dart';
import '../core/plugin_command.dart';
import '../views/plugin_label_view.dart';
import '../views/search_list.dart';

class CommandPageParams {
  final Plugin plugin;
  final PluginCommand command;

  CommandPageParams({required this.plugin, required this.command});
}

class CommandPage extends StatefulWidget {
  static final String routeName = 'command';
  static CommandPage? current;

  final Plugin plugin;
  final PluginCommand command;

  CommandPage({required this.plugin, required this.command}) {
    current = this;
  }

  @override
  State<StatefulWidget> createState() {
    return CommandPageState();
  }
}

class CommandPageState extends State<CommandPage> {
  static CommandPageState? current;

  GlobalKey<SearchListState<PluginResult<SearchResult>>> searchListKey =
      GlobalKey<SearchListState<PluginResult<SearchResult>>>();

  CommandPageState() : super() {
    current = this;
  }

  @override
  void dispose() {
    current = null;
    widget.command.onExit?.call();
    super.dispose();
  }

  Future<List<PluginResult<SearchResult>>> _onSearch(String keyword) async {
    final results = await widget.command.onSearch?.call(keyword) ?? [];
    return results.map<PluginResult<SearchResult>>((result) {
      return PluginResult<SearchResult>(
        plugin: widget.plugin,
        value: result,
      );
    }).toList();
  }

  void _onEnter(PluginResult<SearchResult> item) {
    widget.command.onResultTap?.call(item.value);
  }

  Future<Widget?> _onSelect(PluginResult<SearchResult>? item) async {
    if (item == null) {
      return null;
    }
    final previewWidget =
        await widget.command.onResultPreview?.call(item.value);
    return previewWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        padding: EdgeInsets.all(0),
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SearchList<PluginResult<SearchResult>>(
                key: searchListKey,
                inputPrefix: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.arrow_back),
                ),
                inputSuffix: PluginLabelView(
                  icon: widget.command.icon,
                  title: widget.command.title,
                ),
                searchAtStart: true,
                onSearch: _onSearch,
                onSelect: _onSelect,
                onEnter: _onEnter,
                onEmptyDelete: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
