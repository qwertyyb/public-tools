import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:html/dom.dart' as dom;

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';
import '../../pigeon/app.dart';
import '../../utils/logger.dart';
import 'server.dart';

Future<String> _downloadNodeJs() async {
  const downloadUrl =
      'https://nodejs.org/dist/v16.13.0/node-v16.13.0-darwin-x64.tar.gz';
  final dir = await getApplicationSupportDirectory();
  final filePath = '${dir.path}/node-v16.13.0-darwin-x64.tar.gz';
  final nodeDir = '${dir.path}/node-v16.13.0-darwin-x64/';
  final binDir = '$nodeDir/bin';
  final npmPath = '$binDir/npm';
  final nodePath = '$binDir/node';
  if (File(npmPath).existsSync() && File(nodePath).existsSync()) {
    return binDir;
  }
  // 删除文件，重新下载
  if (File(npmPath).existsSync() || File(nodePath).existsSync()) {
    Directory(nodeDir).deleteSync(recursive: true);
  }
  if (File(filePath).existsSync()) {
    File(filePath).deleteSync();
  }
  final request = await HttpClient().getUrl(Uri.parse(downloadUrl));
  final response = await request.close();
  final file = File(filePath);
  await response.pipe(file.openWrite()).catchError((error) {
    file.deleteSync();
    logger.e('download nodejs error: $error');
    throw error;
  }, test: (error) => false);
  logger.i('download success');
  final process = await Process.run(
    "tar",
    ['-zxf', 'node-v16.13.0-darwin-x64.tar.gz'],
    workingDirectory: dir.path,
  );
  final exitCode = process.exitCode;
  if (exitCode != 0) {
    file.deleteSync();
    throw Exception('download nodejs error');
  }
  logger.i('untar success');
  return binDir;
}

late RemotePluginServer _server;

void _bindServerListener() async {
  _server.on('toast', (data) {
    showToast(data["content"]);
  });
  _server.on('hideApp', (data) async {
    await Service().hideApp();
  });
  _server.on('showApp', (data) async {
    await windowManager.show();
  });
  _server.on('updateResults', (data) {
    final jsonCommand = data['command'];
    final command = remotePlugin.commands
        .firstWhereOrNull((command) => command.id == jsonCommand['id']);
    if (command == null) return;
    command.updateResults(
      data['results']
          .map<SearchResult>((element) => SearchResult.fromJson(element))
          .toList(),
    );
  });
}

void _onRegistery() {
  _downloadNodeJs().then((binPath) {
    runClient(binPath);
  });
  _server = RemotePluginServer(
    onDisconnect: () {
      remotePlugin.commands = [];
    },
    onReady: () async {
      final data = await _server.invoke("getCommands", {});
      logger.i('getCommands: $data');
      remotePlugin.commands = data["commands"].map<PluginCommand>((element) {
        final command = PluginCommand.fromJsonAndFunction(
          element,
          onEnter: () {
            _server.invoke("onEnter", {
              "command": element,
            });
          },
          onSearch: (String keyword) async {
            final data = await _server
                .invoke('onSearch', {"keyword": keyword, "command": element});
            return data["results"]
                .map<SearchResult>((element) => SearchResult.fromJson(element))
                .toList();
          },
          onResultTap: (SearchResult result) async {
            _server.invoke('onResultTap', {
              "command": element,
              "result": result.toJson(),
            });
          },
          onExit: () async {
            _server.invoke("onExit", {
              "command": element,
            });
          },
          onResultPreview: (SearchResult result) async {
            final data = await _server.invoke('onResultSelected', {
              "command": element,
              "result": result.toJson(),
            });
            if (data["html"] == null) return null;

            CustomRenderMatcher isFlutterContainer = (context) =>
                context.tree.element?.localName == 'flutter-container';

            Widget _getFirstWidget(List<Widget> widgets) {
              return widgets.isEmpty ? Text('no child') : widgets.first;
            }

            List<Widget> _renderNodes(dom.NodeList nodes) {
              logger.i(nodes.where((node) => node is dom.Element));
              return nodes
                  .where((node) => node is dom.Element)
                  .map<Widget>((node) {
                final element = node as dom.Element;
                if (element.localName == 'row') {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _renderNodes(element.nodes),
                  );
                } else if (element.localName == 'text-button') {
                  return TextButton(
                    child: _getFirstWidget(_renderNodes(element.nodes)),
                    onPressed: () {
                      logger.i(element.attributes);
                      LinkedHashMap args = LinkedHashMap<Object, String>.from(
                          element.attributes);
                      args.removeWhere((key, value) {
                        if (key is String) {
                          return !(key).startsWith('data-');
                        }
                        return true;
                      });
                      final fargs = args.map((key, value) => MapEntry(
                          (key as String).substring('data-'.length), value));
                      _server.invoke('event', {
                        'event': 'onPressed',
                        'handlerName': element.attributes['onpressed'],
                        'handlerArgs': fargs,
                      });
                    },
                  );
                } else if (element.localName == 'spacer') {
                  return Spacer();
                } else if (element.localName == 'text') {
                  return Text(element.text);
                } else if (element.localName == 'icon') {
                  return Icon(
                    Icons.download,
                    size: double.parse(element.attributes['size'] ?? '20'),
                  );
                }
                return Text('unsupport element');
              }).toList();
            }

            CustomRender flutterContainerRender = CustomRender.widget(
                widget: (RenderContext context, buildChildren) {
              final widget =
                  _renderNodes(context.tree.element!.nodes).firstOrNull;
              if (widget == null) return Text('no child');
              return widget;
            });
            return Html(
              data: data["html"],
              customRenders: {
                isFlutterContainer: flutterContainerRender,
              },
              tagsList: Html.tags..addAll(['flutter-container']),
            );
          },
        );
        return command;
      }).toList();
    },
  );
  _bindServerListener();
  logger.i('server is running');
}

final remotePlugin = Plugin(
  id: 'remote',
  title: '远程插件',
  subtitle: '通过websocket通信，可用其它语言支持的插件',
  description: '通过websocket通信，可用其它语言支持的插件',
  icon: '',
  commands: [],
  onRegister: _onRegistery,
);
