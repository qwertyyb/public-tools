import 'package:flutter/material.dart';

import '../core/plugin.dart';
import '../core/plugin_command.dart';
import '../core/plugin_manager.dart';
import '../views/search_list.dart';

class MainPage extends StatefulWidget {
  static final String routeName = 'main';

  MainPage();

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  Future<List<PluginResult<PluginCommand>>> _onSearch(String keyword) {
    return Future.value(PluginManager.instance.searchCommands(keyword));
  }

  void _onEnter(PluginResult<PluginCommand> item) {
    PluginManager.instance.onCommand(item.value, item.plugin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
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
              child: SearchList<PluginResult<PluginCommand>>(
                onSearch: _onSearch,
                onEnter: _onEnter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
