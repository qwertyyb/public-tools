import 'package:public_tools/core/Plugin.dart';
import 'package:public_tools/core/PluginListItem.dart';

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
    onUpdateList(setResult);
    send("keyword", {"keyword": keyword});
  }

  @override
  onTap(PluginListItem<String> item) {
    send("tap", {"id": item.id});
  }
}
