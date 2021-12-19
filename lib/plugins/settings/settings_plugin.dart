import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_result_item.dart';
import 'package:public_tools/plugins/settings/basic.dart';
import 'package:public_tools/plugins/settings/utils.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPlugin extends Plugin {
  List<String> keywords = ['settings', 'preferences', '设置'];

  List<PluginListItem> commands = [
    PluginListItem(
      title: '设置',
      subtitle: 'Public设置',
      icon: null,
    )
  ];

  SettingsPlugin() {
    this._refreshHotkey();
  }

  onQuery(query, setResult) {
    var match = keywords.where((element) => element.contains(query)).length > 0;
    if (match) {
      setResult(commands);
    } else {
      setResult([]);
    }
  }

  onTap(item, {enterItem}) {
    // @todo 跳转到设置页面
    enterItem();
  }

  @override
  void onEnter(PluginListItem item) {
    super.onEnter(item);
  }

  @override
  void onSearch(
    String keyword,
    void Function(List<PluginListItem> list) setResult,
  ) {
    final basicItem =
        PluginListItem<String>(title: "基础", subtitle: '基础设置', id: 'basic');
    final hotkeyItem =
        PluginListItem<String>(title: '快捷键', subtitle: '插件快捷键', id: 'hotkey');
    setResult([
      basicItem,
      hotkeyItem,
    ]);
  }

  void _refreshHotkey() async {
    await HotKeyManager.instance.unregisterAll();
    final hotkey = await getHotkeyFromPrefs();
    HotKeyManager.instance.register(
      hotkey,
      keyDownHandler: (hotKey) async {
        await windowManager.show();
      },
    );
  }

  @override
  void onResultSelect(PluginListItem item, {setPreview}) {
    if (item.id == 'basic')
      return setPreview(BasicView(
        onHotkeyChange: this._refreshHotkey,
      ));
    setPreview(null);
    return null;
  }
}
