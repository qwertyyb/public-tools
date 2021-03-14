import 'package:flutter/material.dart';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';

import 'package:oktoast/oktoast.dart';
import 'package:window_activator/window_activator.dart';

import 'package:public_tools/core/PluginManager.dart';
import 'package:public_tools/plugins/application/application.dart';
import 'package:public_tools/plugins/clipboard.dart';
import 'package:public_tools/plugins/command/command.dart';
import './views/MainView.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Public'),
    ));
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PluginManager pluginManager = PluginManager.instance;

  @override
  void initState() {
    // 注册快捷键
    HotkeyShortcuts.register("command+space", () async {
      await WindowActivator.activateWindow();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
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
          children: <Widget>[Expanded(child: MainView())],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
