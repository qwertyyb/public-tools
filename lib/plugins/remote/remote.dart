import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_result_item.dart';

import 'server.dart';

class RemotePlugin extends Plugin<String> {
  RemotePlugin() {
    runServer();
    print("server is running");
  }

  @override
  void onQuery(String keyword,
      void Function(List<PluginListItem<String>> list) setResult) {
    receivers.clear();
    enterItemReceivers.clear();
    setLoading(true);
    onUpdateList(setResult);
    onUpdateList((list) {
      setLoading(false);
    });
    send("keyword", {"keyword": keyword});
  }

  @override
  onTap(PluginListItem<String> item, {enterItem}) {
    enterItemReceivers.clear();
    enterItemReceivers.add(enterItem);
    send("tap", {'item': item});
  }

  @override
  void onExit(PluginListItem item) {
    send("exit", {});
    super.onExit(item);
  }
}
