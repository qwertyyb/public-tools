import 'PluginListItem.dart';

abstract class Plugin {
  String label;

  String icon;

  void onCreated() {}

  void onInput(
      String keyword, void Function(List<PluginListItem> list) setResult);
  
  onTap(PluginListItem item);
}
