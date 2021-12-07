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

// 只调用一次的函数
T Function(A a, B b) once<A, B, T>(T Function(A a, B b) func) {
  var alreadyRun = false;
  T t;
  return (A a, B b) {
    if (alreadyRun) return t;
    return func(a, b);
  };
}

// 可取消的函数
T Function(A a, B b) cancelable<A, B, T>(T Function(A a, B b) func) {
  bool canceled = false;
  T t;
  var canceledFn = (A a, B b) {
    if (!canceled) {
      return func(a, b);
    }
    return t;
  };
  return canceledFn;
}
