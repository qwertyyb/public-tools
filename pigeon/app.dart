import 'package:pigeon/pigeon.dart';

class InstalledApplication {
  String name;
  String path;
  String icon;
  String pinyin;
}

// Flutter 调用原生代码

@HostApi()
abstract class Service {
  @async
  List<InstalledApplication> getInstalledApplicationList();
}
