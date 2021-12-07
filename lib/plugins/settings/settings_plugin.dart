import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';

class SettingsPlugin extends Plugin {
  List<String> keywords = ['settings', 'preferences', '设置'];

  List<PluginListItem> commands = [
    PluginListItem(
      title: '设置',
      subtitle: 'Public设置',
      icon: null,
    )
  ];

  onQuery(query, setResult) {
    var match = keywords.where((element) => element.contains(query)).length > 0;
    if (match) {
      setResult(commands);
    } else {
      setResult([]);
    }
  }

  onTap(item) {
    // @todo 跳转到设置页面
  }
}
