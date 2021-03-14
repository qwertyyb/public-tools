import 'dart:async';
import 'package:hotkey_shortcuts/hotkey_shortcuts.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:oktoast/oktoast.dart';
import 'package:public_tools/core/PluginListItem.dart';
import '../core/Plugin.dart';
import '../config.dart';

enum ContentType { text, image }

Future<Database> getDatabase() async {
  var path = await Config.getDatabasePath();
  return openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    await db.execute('''
        create table ${_PasteItem.tableName} (
          id integer primary key autoincrement,
          summary text not null,
          updatedAt NUMERIC not null,
          contentType INTEGER not null,
          text text not null)
        ''');
  });
}

class _PasteItem extends PluginListItem {
  static String tableName = 'clipboardHistory';
  String summary;
  DateTime updatedAt;
  ContentType contentType;
  String text;

  _PasteItem({
    this.summary,
    this.updatedAt,
    this.contentType,
    this.text,
    String title,
    String subtitle,
    String icon,
  }) : super(title: title, subtitle: subtitle, icon: icon);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'summary': summary,
      'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
      'contentType': contentType.index,
      'text': text
    };
    if (id != null) {
      map['id'] = int.parse(id);
    }
    return map;
  }

  _PasteItem.fromMap(Map<String, dynamic> map) {
    final String str = map['summary'];
    id = map['id'].toString();
    summary = str.replaceAll("\n", "").trim();
    text = map['text'].toString();
    contentType = ContentType.values[map['contentType']];
    updatedAt = DateTime.parse(map['updatedAt']);
  }
}

class PasteItemHelper {
  // 工厂模式
  factory PasteItemHelper() => _getInstance();
  static PasteItemHelper get instance => _getInstance();
  static PasteItemHelper _instance;
  PasteItemHelper._internal() {
    // 初始化
  }
  static PasteItemHelper _getInstance() {
    if (_instance == null) {
      _instance = new PasteItemHelper._internal();
    }
    return _instance;
  }

  Future<List<_PasteItem>> query(
      {String where, List whereArgs, List<String> columns}) async {
    var db = await getDatabase();
    var results = await db.query(_PasteItem.tableName,
        orderBy: 'updatedAt desc',
        columns: columns,
        where: where,
        whereArgs: whereArgs);
    return results.map((e) {
      return _PasteItem.fromMap(e);
    }).toList();
  }

  Future<_PasteItem> get(int id) async {
    return getDatabase().then((db) async {
      var maps = await db.query(_PasteItem.tableName,
          columns: ['id', 'updatedAt', 'summary', 'text', 'contentType'],
          where: 'id = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return _PasteItem.fromMap(maps.first);
      }
      return null;
    });
  }

  Future<int> delete(int id) async {
    return getDatabase().then((db) {
      return db.delete(_PasteItem.tableName, where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> update(_PasteItem pasteItem) async {
    return getDatabase().then((db) {
      return db.update(_PasteItem.tableName, pasteItem.toMap(),
          where: 'id = ?', whereArgs: [pasteItem.id]);
    });
  }

  Future<int> save(_PasteItem pasteItem) async {
    if (pasteItem.id != null) {
      return this.update(pasteItem);
    }
    var insertId = await getDatabase().then((db) {
      return db.insert(_PasteItem.tableName, pasteItem.toMap());
    });
    return insertId;
  }
}

class ClipboardPlugin implements Plugin {
  ClipboardPlugin({this.onChange}) {
    _startListenChange().listen(onNewItemReceived);
  }

  var label = '剪切板';

  var icon = "https://vfiles.gtimg.cn/vupload/20210220/586e451613797978732.png";

  onCreated() {}

  onInput(String keyword, setResult) async {
    var list = await PasteItemHelper.instance
        .query(where: 'text like ?', whereArgs: ['%' + keyword + '%']);
    setResult(list.map((e) {
      return _PasteItem(
          title: e.summary,
          subtitle: DateFormat('yyyy-MM-dd HH:mm:ss').format(e.updatedAt),
          icon: 'https://img.icons8.com/officel/80/000000/paste-as-text.png',
          text: e.text);
    }).toList());
  }

  onTap(item) {
    Clipboard.setData(ClipboardData(text: (item as _PasteItem).text));
    showToast("复制成功");
    HotkeyShortcuts.pasteToFrontestApp();
  }

  void Function(List<Map<String, String>>) onChange;

  final _streamController = StreamController<String>();
  Stream<String> _startListenChange() {
    String lastText;
    var callback = (Timer timer) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        if (data == null) return;
        if (lastText == data.text) {
          return print('数据一致');
        }
        lastText = data.text;
        print(this._streamController);
        this._streamController.add(data.text);
        print('数据不一致');
      });
    };
    Timer.periodic(Duration(seconds: 2), callback);
    return _streamController.stream.asBroadcastStream();
  }

  Future<_PasteItem> existsItem(text) {
    return PasteItemHelper.instance
        .query(where: 'text = ?', whereArgs: [text]).then((results) {
      return results.length > 0 ? results[0] : null;
    });
  }

  void onNewItemReceived(event) async {
    print("新的粘贴板内容: $event");
    var item = _PasteItem(
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
      var list = await PasteItemHelper.instance.query();
      this.onChange(list.map((e) {
        var item = Map<String, String>();
        item["title"] = e.summary;
      }).toList());
    }
  }
}
