import 'package:flutter/material.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/pages/command_page.dart';
import 'package:public_tools/views/search_list.dart';

class MainPage extends StatefulWidget {
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

  Future<Widget> _onSelect(PluginResult<PluginCommand> item) {
    return null;
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
                onSelect: _onSelect,
                onEnter: (PluginResult<PluginCommand> item) {
                  Navigator.pushNamed(context, 'command',
                      arguments: CommandPageParams(
                          plugin: item.plugin, command: item.value));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
