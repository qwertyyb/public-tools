import 'package:sqflite/sqflite.dart';
import '../config.dart';
import '../models/PasteItem.dart';

class Utils {
  // 工厂模式
  factory Utils() => _getInstance();
  static Utils get instance => _getInstance();
  static Utils _instance;
  Utils._internal() {
    // 初始化
  }
  static Utils _getInstance() {
    if (_instance == null) {
      _instance = new Utils._internal();
    }
    return _instance;
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
}
