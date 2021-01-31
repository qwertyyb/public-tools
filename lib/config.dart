import "package:path_provider/path_provider.dart";

Future<String> getDatabasePath() {
  return getApplicationSupportDirectory()
      .then((value) => value.path + '/database.sqlite');
}
