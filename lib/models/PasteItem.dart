import 'package:intl/intl.dart';
import '../utils/utils.dart';

enum ContentType { text, image }

class PasteItem {
  static String tableName = 'clipboardHistory';
  int id;
  String summary;
  DateTime updatedAt;
  ContentType contentType;
  String text;

  PasteItem({this.summary, this.updatedAt, this.contentType, this.text});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'summary': summary,
      'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
      'contentType': contentType.index,
      'text': text
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  PasteItem.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    summary = map['summary'];
    text = map['text'];
    contentType = ContentType.values[map['contentType']];
    updatedAt = DateTime.parse(map['updatedAt']);
  }

  Future<int> save() async {
    if (id != null) {
      return this.update();
    }
    var insertId = await Utils.instance.getDatabase().then((db) {
      return db.insert(PasteItem.tableName, this.toMap());
    });
    return insertId;
  }
  Future<PasteItem> get() async {
    return Utils.instance.getDatabase().then((db) async {
      var maps = await db.query(PasteItem.tableName,
          columns: ['id', 'updatedAt', 'summary', 'text', 'contentType'],
          where: 'id = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return PasteItem.fromMap(maps.first);
      }
      return null;
    });
  }

  Future<int> delete() async {
    return Utils.instance.getDatabase().then((db) {
      return db.delete(PasteItem.tableName, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> update() async {
    return Utils.instance.getDatabase().then((db) {
      return db.update(PasteItem.tableName, toMap(),
          where: 'id = ?', whereArgs: [id]);
    });
  }

  Future close() async => Utils.instance.getDatabase().then((db) {
        return db.close();
      });
}
