import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/pages/command_page.dart';
import 'package:public_tools/pages/main_page.dart';
import 'package:window_manager/window_manager.dart';
import 'views/main_view.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  // For hot reload, `unregisterAll()` needs to be called.
  hotKeyManager.unregisterAll();

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
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return ChangeNotifierProvider.value(
        value: PluginManager.instance.state,
        child: MaterialApp(
          color: Color.fromARGB(255, 0, 0, 0),
          title: "hello",
          routes: {
            '/settings': (BuildContext context) => SettingsPage(),
            // '/command': (BuildContext context) => Scaffold(body: MainView()),
          },
          onGenerateRoute: (settings) {
            if (settings.name == 'command') {
              final args = settings.arguments as CommandPageParams;
              return MaterialPageRoute(
                builder: (context) => CommandPage(
                  plugin: args.plugin,
                  command: args.command,
                ),
              );
            }
            return null;
          },
          home: MainPage(),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
