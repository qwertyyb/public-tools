import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';
import 'pages/command_page.dart';
import 'pages/main_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  // For hot reload, `unregisterAll()` needs to be called.
  hotKeyManager.unregisterAll();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://a6a92efa2ef846f4941d726885cab675@o1198024.ingest.sentry.io/6320659';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MainApp()),
  );
}

class MainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: Color.fromARGB(255, 0, 0, 0),
        title: "hello",
        navigatorKey: navigatorKey,
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
        onGenerateRoute: (settings) {
          if (settings.name == 'command') {
            final args = settings.arguments as CommandPageParams?;
            return PageRouteBuilder(
              settings: settings,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) => CommandPage(
                plugin: args!.plugin,
                command: args.command,
              ),
            );
          }
          return null;
        },
        home: MainPage(),
      ),
    );
  }
}
