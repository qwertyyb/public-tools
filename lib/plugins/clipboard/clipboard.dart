import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/tomorrow-night.dart';
import 'package:intl/intl.dart';
import 'package:public_tools/core/plugin_manager.dart';
import 'package:public_tools/pigeon/instance.dart';

import 'package:sqflite/sqflite.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import '../../core/plugin.dart';
import '../../config.dart';
import '../../core/plugin_command.dart';
import '../../utils/logger.dart';

enum ContentType { text, image }

class ClipboardDataType {
  static String string = 'public.utf8-plain-text';

  static String tiff = 'public.tiff';

  static String html = 'public.html';
}

final initialScript = [
  '''
  create table clipboardHistory (
    id integer primary key autoincrement,
    summary text not null,
    updatedAt NUMERIC not null,
    contentType INTEGER not null,
    text text not null)
'''
];

final migrations = [
  '''
  alter table clipboardHistory add column binary blob;
  alter table clipboardHistory add column createdAt NUMERIC default '2022-05-06 21:25:00';
  '''
];

final config = MigrationConfig(
    initializationScript: initialScript, migrationScripts: migrations);

Future<Database>? lastOpenDatabase;

Future<Database> getDatabase() async {
  if (lastOpenDatabase != null) return lastOpenDatabase!;

  Future<Database> openDatabase() async {
    var path = await Config.getDatabasePath();
    return openDatabaseWithMigration(path, config);
  }

  lastOpenDatabase = openDatabase();
  return lastOpenDatabase!;
}

class _PasteItem {
  static String tableName = 'clipboardHistory';
  int? id;
  String? summary;
  DateTime? updatedAt;
  DateTime createdAt = DateTime.now();
  ContentType? contentType;
  String? text;
  Uint8List? binary;

  _PasteItem({
    this.summary,
    this.updatedAt,
    this.contentType,
    this.text,
    this.binary,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'summary': summary,
      'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt!),
      'contentType': contentType!.index,
      'text': text,
      'binary': binary,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  _PasteItem.fromMap(Map<String, dynamic> map) {
    final String str = map['summary'];
    id = map['id'] as int;
    summary = str.replaceAll("\n", "").trim();
    text = map['text'].toString();
    contentType = ContentType.values[map['contentType']];
    createdAt = DateTime.parse(map['createdAt']);
    updatedAt = DateTime.parse(map['updatedAt']);
    binary = map['binary'] as Uint8List?;
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

  Future<List<_PasteItem>> query(
      {String? where, List? whereArgs, List<String>? columns}) async {
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

  Future<_PasteItem?> get(int id) async {
    return getDatabase().then((db) async {
      var maps = await db.query(_PasteItem.tableName,
          columns: [
            'id',
            'createdAt',
            'updatedAt',
            'summary',
            'text',
            'contentType',
            'binary'
          ],
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

var lastKeyword = '';

Future<List<SearchResult>> search(String keyword) async {
  var list = await PasteItemHelper.instance!
      .query(where: 'text like ?', whereArgs: ['%' + keyword + '%']);
  return list.map((e) {
    return SearchResult(
        id: (e.id ?? '').toString(),
        title: e.summary!,
        subtitle: DateFormat('yyyy-MM-dd HH:mm:ss').format(e.updatedAt!),
        icon: e.contentType == ContentType.text
            ? 'https://img.icons8.com/external-prettycons-flat-prettycons/94/000000/external-text-text-formatting-prettycons-flat-prettycons-1.png'
            : 'https://img.icons8.com/external-prettycons-flat-prettycons/94/000000/external-picture-essentials-prettycons-flat-prettycons.png',
        description: e.text!);
  }).toList();
}

final _command = PluginCommand(
  id: 'clipboard',
  title: "剪切板",
  subtitle: "查看剪切板历史",
  description: "查看剪切板历史",
  keywords: ["cp", "clipboard history", "jqb"],
  icon: "https://vfiles.gtimg.cn/vupload/20210220/586e451613797978732.png",
  mode: CommandMode.listView,
  onSearch: (String keyword) async {
    lastKeyword = keyword;
    return search(keyword);
  },
  onResultPreview: (SearchResult result) async {
    final selected = await PasteItemHelper.instance!.get(int.parse(result.id));
    if (selected?.contentType == ContentType.image) {
      return Padding(
        padding: EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Image.memory(
              selected!.binary!,
              width: 300,
            )
          ],
        ),
      );
    }
    return Future.value(
      HighlightView(
        // The original code to be highlighted
        result.description!,

        // Specify language
        // It is recommended to give it a value for performance
        language: 'dart',

        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: tomorrowNightTheme,

        // Specify padding
        padding: EdgeInsets.all(12),

        // Specify text style
        // textStyle: TextStyle(
        //   fontFamily: 'My awesome monospace font',
        //   fontSize: 16,
        // ),
      ),
    );
  },
  onResultTap: (SearchResult result) async {
    final selected = await PasteItemHelper.instance!.get(int.parse(result.id));
    logger.i(selected?.contentType);
    if (selected?.contentType == ContentType.text) {
      await platformService.setClipboardData(
        Uint8List.fromList(utf8.encode(result.title)),
        ClipboardDataType.string,
      );
    } else if (selected?.contentType == ContentType.image) {
      await platformService.setClipboardData(
        selected!.binary!,
        ClipboardDataType.tiff,
      );
    }
    showToast("复制成功");
    platformService.pasteToFrontestApp();
  },
);

class CustomClipboardListener extends ClipboardListener {
  final void Function(ContentType, Uint8List, String) onChange;

  CustomClipboardListener(this.onChange);

  @override
  void onClipboardChanged() async {
    super.onClipboardChanged();
    final imgdata =
        await platformService.readClipboardData(ClipboardDataType.tiff);
    if (imgdata != null) {
      final image = await decodeImageFromList(imgdata);
      final summary = 'Image(${image.width}x${image.height})';
      return onChange(ContentType.image, imgdata, summary);
    }
    final data =
        await platformService.readClipboardData(ClipboardDataType.string);
    if (data != null) {
      return onChange(ContentType.text, data, String.fromCharCodes(data));
    }
  }
}

void _start() {
  clipboardWatcher.addListener(CustomClipboardListener(_onNewItemReceived));
  clipboardWatcher.start();
}

Future<_PasteItem?> _existsItem(
    text, Uint8List? binary, ContentType contentType) {
  return PasteItemHelper.instance!.query(
      where: 'text = ? and contentType = 1 or binary = ? and contentType != 1',
      whereArgs: [text, binary]).then((results) {
    return results.length > 0 ? results[0] : null;
  });
}

void _onNewItemReceived(
    ContentType contentType, Uint8List data, String text) async {
  var item = await _existsItem(text, data, contentType);
  if (item != null) {
    logger.i('数据库已存在，仅更新时间');
    item.updatedAt = DateTime.now();
  } else {
    item = _PasteItem(
      contentType: contentType,
      text: text,
      updatedAt: DateTime.now(),
      summary: text,
      binary: data,
    );
  }

  await PasteItemHelper.instance!.save(item);

  final list = await search(lastKeyword);
  PluginManager.instance.updateResults(_command, list);
}

final clipboardPlugin = Plugin(
  id: "clipboard",
  title: "剪切板",
  subtitle: '查看剪切板历史',
  description: "查看剪切板历史",
  icon: "https://vfiles.gtimg.cn/vupload/20210220/586e451613797978732.png",
  commands: [_command],
  onRegister: _start,
);
