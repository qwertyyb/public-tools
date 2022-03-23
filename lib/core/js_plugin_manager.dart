import 'dart:io';

import 'package:flutter_js/flutter_js.dart';
import 'package:public_tools/core/plugin.dart';

class JSPluginManager {
  JavascriptRuntime jsRuntime = getJavascriptRuntime();

  register(Map<String, dynamic> configJson) async {
    // final pluginConfig = Plugin.fromJson(configJson);
    // final mainFile = File(pluginConfig.main);
    // final mainContent = await mainFile.readAsString();
    // jsRuntime.evaluateAsync(mainContent);
  }
}
