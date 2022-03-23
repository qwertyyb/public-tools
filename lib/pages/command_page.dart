import 'package:flutter/material.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/views/plugin_label_view.dart';
import 'package:public_tools/views/search_list.dart';

class CommandPageParams {
  final Plugin plugin;
  final PluginCommand command;

  CommandPageParams({this.plugin, this.command});
}

class CommandPage extends StatefulWidget {
  final Plugin plugin;
  final PluginCommand command;

  CommandPage({this.plugin, this.command});

  @override
  State<StatefulWidget> createState() {
    return _CommandPageState();
  }
}

class _CommandPageState extends State<CommandPage> {
  Widget preview;

  Future<List<PluginResult<SearchResult>>> _onSearch(String keyword) async {
    final results = await widget.plugin.onSearch(keyword, widget.command);
    return results.map<PluginResult<SearchResult>>((result) {
      return PluginResult<SearchResult>(
        plugin: widget.plugin,
        value: result,
      );
    }).toList();
  }

  void _onEnter(PluginResult<SearchResult> item) {
    widget.plugin.onResultTap(item.value);
  }

  Future<Widget> _onSelect(PluginResult<SearchResult> item) async {
    final previewWidget = await widget.plugin.onResultSelected(item.value);
    setState(() {
      preview = previewWidget;
    });
    return previewWidget;
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
              child: SearchList<PluginResult<SearchResult>>(
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
