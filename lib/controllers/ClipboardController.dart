import 'dart:async';
import 'package:flutter/services.dart';

class ClipboardController {
  static Future<ClipboardData> getText() async {
    return Clipboard.getData(Clipboard.kTextPlain);
  }

  static StreamController<String> streamController = StreamController<String>();

  static Stream<String> startListener() {
    String lastText;
    var callback = (Timer timer) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        if (lastText == data.text) {
          return print('数据一致');
        }
        lastText = data.text;
        ClipboardController.streamController.add(data.text);
        print('数据不一致');
      });
    };
    Timer.periodic(Duration(seconds: 2), callback);
    return ClipboardController.streamController.stream.asBroadcastStream();
  }
}
