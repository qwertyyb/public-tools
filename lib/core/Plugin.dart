import 'package:ypaste_flutter/models/CommonListItem.dart';

abstract class Plugin {
  String label;

  String icon;

  void onCreated() {}

  void onInput(
      String keyword, void Function(List<CommonListItem> list) setResult);
}
