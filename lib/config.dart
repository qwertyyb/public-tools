import "package:path_provider/path_provider.dart";

class Config {
  static Future<String> getDatabasePath() async {
    var value = await getApplicationSupportDirectory();
    print("returned: ${value.path}/database.sqlite");
    return "${value.path}/database.sqlite";
  }
}
