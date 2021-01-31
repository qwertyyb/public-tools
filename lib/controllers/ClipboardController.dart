import 'package:flutter/services.dart';

class ClipboardController {
  static Future<ClipboardData> getText() async {
    return Clipboard.getData(Clipboard.kTextPlain);
  }
}
