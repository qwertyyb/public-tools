import 'package:intl/intl.dart';
import '../utils/utils.dart';

enum ContentType { text, image }

class PasteItem {
  static String tableName = 'clipboardHistory';
  int? id;
  String? summary;
  DateTime? updatedAt;
  ContentType? contentType;
  String? text;

  PasteItem({this.summary, this.updatedAt, this.contentType, this.text});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'summary': summary,
      'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt!),
      'contentType': contentType!.index,
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
    text = map['text'].toString();
    contentType = ContentType.values[map['contentType']];
    updatedAt = DateTime.parse(map['updatedAt']);
  }
}

class PasteItemHelper {
  // 工厂模式
  factory PasteItemHelper() => _getInstance()!;
  static PasteItemHelper? get instance => _getInstance();
  static PasteItemHelper? _instance;
  PasteItemHelper._internal() {
    // 初始化
  }
  static PasteItemHelper? _getInstance() {
    if (_instance == null) {
      _instance = new PasteItemHelper._internal();
    }
    return _instance;
  }

  Future<List<PasteItem>> query(
      {String? where, List? whereArgs, List<String>? columns}) async {
    var db = await Utils.instance!.getDatabase();
    var results = await db.query(PasteItem.tableName,
        orderBy: 'updatedAt desc',
        columns: columns,
        where: where,
        whereArgs: whereArgs);
    return results.map((e) {
      return PasteItem.fromMap(e);
    }).toList();
  }

  Future<PasteItem?> get(int id) async {
    return Utils.instance!.getDatabase().then((db) async {
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
    return Utils.instance!.getDatabase().then((db) {
      return db.delete(PasteItem.tableName, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> update(PasteItem pasteItem) async {
    return Utils.instance!.getDatabase().then((db) {
      return db.update(PasteItem.tableName, pasteItem.toMap(),
          where: 'id = ?', whereArgs: [pasteItem.id]);
    });
  }

  Future<int> save(PasteItem pasteItem) async {
    if (pasteItem.id != null) {
      return this.update(pasteItem);
    }
    var insertId = await Utils.instance!.getDatabase().then((db) {
      return db.insert(PasteItem.tableName, pasteItem.toMap());
    });
    return insertId;
  }
}
