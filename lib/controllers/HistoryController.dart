import 'package:ypaste_flutter/controllers/ClipboardController.dart';
import 'package:ypaste_flutter/models/PasteItem.dart';
import '../utils/utils.dart';

class HistoryController {
  Future<List<PasteItem>> query() async {
    var db =  await Utils.instance.getDatabase();
    var results = await db.query(PasteItem.tableName,
        columns: ['id', 'updatedAt', 'summary', 'text', 'contentType']);
    return results.map((e) {
      return PasteItem.fromMap(e);
    }).toList();
  }

  Function onChange;

  HistoryController({ this.onChange }) {
    ClipboardController.startListener().listen((event) async{
      print("新的粘贴板内容: $event");
      var item = PasteItem(
        contentType: ContentType.text,
        text: event,
        updatedAt: DateTime.now(),
        summary: event,
      );
      await item.save();
      if (onChange != null) {
        this.onChange();
      }
    });
  }
  Future<List<PasteItem>> refresh() {
    return query();
  }
}
