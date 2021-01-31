import 'package:ypaste_flutter/controllers/ClipboardController.dart';
import 'package:ypaste_flutter/models/PasteItem.dart';

class HistoryController {
  HistoryController() {
    ClipboardController.startListener().listen((event) {
      print("新的粘贴板内容: $event");
      var item = PasteItem(
        contentType: ContentType.text,
        text: event,
        updatedAt: DateTime.now(),
        summary: event,
      );
      item.insert(item);
    });
  }
}
