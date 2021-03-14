import "package:path_provider/path_provider.dart";

class Config {
  // 工厂模式
  factory Config() =>_getInstance();
  static Config get instance => _getInstance();
  static Config _instance;
  Config._internal() {
    // 初始化
  }
  static Config _getInstance() {
    if (_instance == null) {
      _instance = new Config._internal();
    }
    return _instance;
  }
  static Future<String> getDatabasePath() async {
    var value = await getApplicationSupportDirectory();
    return "${value.path}/database.sqlite";
  }
}
