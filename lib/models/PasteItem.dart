import 'package:sqflite/sqflite.dart';
import '../config.dart';

enum ContentType { text, image }

class PasteItem {
  static String tableName = 'clipboardHistory';
  int id;
  String summary;
  DateTime updatedAt;
  ContentType contentType;
  String text;

  PasteItem({this.summary, this.updatedAt, this.contentType, this.text}) {
    print(getDatabase());
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'summary': summary,
      'updatedAt': updatedAt,
      'contentType': contentType,
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
    contentType = map['contentType'];
    updatedAt = map['updatedAt'];
  }

  Future<Database> getDatabase() async {
    var path = await Config.getDatabasePath();
    return openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        create table ${PasteItem.tableName} (
          id integer primary key autoincrement,
          summary text not null,
          updatedAt NUMERIC not null,
          contentType INTEGER not null,
          text integer not null)
        ''');
    });
  }

  Future<PasteItem> insert(PasteItem pasteItem) async {
    id = await this.getDatabase().then((db) {
      return db.insert(PasteItem.tableName, pasteItem.toMap());
    });
    return this;
  }

  Future<PasteItem> get(int id) async {
    return this.getDatabase().then((db) async {
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

  Future<int> delete(int id) async {
    return this.getDatabase().then((db) {
      return db.delete(PasteItem.tableName, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> update(PasteItem pasteItem) async {
    return getDatabase().then((db) {
      return db.update(PasteItem.tableName, pasteItem.toMap(),
          where: 'id = ?', whereArgs: [pasteItem.id]);
    });
  }

  Future close() async => getDatabase().then((db) {
        return db.close();
      });
}
