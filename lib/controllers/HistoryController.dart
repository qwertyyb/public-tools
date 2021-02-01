import 'package:ypaste_flutter/controllers/ClipboardController.dart';
import 'package:ypaste_flutter/models/PasteItem.dart';

class HistoryController {
  // 工厂模式
  factory HistoryController() => _getInstance();
  static HistoryController get instance => _getInstance();
  static HistoryController _instance;
  HistoryController._internal() {
    // 初始化
    ClipboardController.startListener().listen(onNewItemReceived);
  }

  static HistoryController _getInstance() {
    if (_instance == null) {
      _instance = new HistoryController._internal();
    }
    return _instance;
  }

  void Function() onChange;

  Future<PasteItem> existsItem(text) {
    return PasteItemHelper.instance
        .query(where: 'text = ?', whereArgs: [text]).then((results) {
      return results.length > 0 ? results[0] : null;
    });
  }

  void onNewItemReceived(event) async {
    print("新的粘贴板内容: $event");
    var item = PasteItem(
      contentType: ContentType.text,
      text: event,
      updatedAt: DateTime.now(),
      summary: event,
    );
    var alreadyExistsItem = await existsItem(event);
    if (alreadyExistsItem != null) {
      print("数据库已存在，仅更新时间");
      item.id = alreadyExistsItem.id;
    }
    await PasteItemHelper.instance.save(item);
    if (onChange != null) {
      this.onChange();
    }
  }

  Future<int> deleteItem(int id) {
    return PasteItemHelper.instance.delete(id).then((res) {
      onChange();
      return res;
    });
  }

  Future<List<PasteItem>> refresh() {
    return PasteItemHelper.instance.query();
  }
}
