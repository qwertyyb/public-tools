import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';
import '../../pigeon/app.dart';
import '../../utils/logger.dart';
import 'server.dart';

Future<String> _downloadNodeJs() async {
  const downloadUrl =
      'https://nodejs.org/dist/v16.13.1/node-v16.13.1-darwin-x64.tar.gz';
  final dir = await getApplicationSupportDirectory();
  final filePath = '${dir.path}/node-v16.13.1-darwin-x64.tar.gz';
  final nodeDir = '${dir.path}/node-v16.13.1-darwin-x64';
  if (File(filePath).existsSync()) return '$nodeDir/bin';
  final request = await HttpClient().getUrl(Uri.parse(downloadUrl));
  final response = await request.close();
  final file = File(filePath);
  await response.pipe(file.openWrite()).catchError((error) {
    file.deleteSync();
  }, test: (error) => false);
  Process.run("tar", ['-zxf', 'node-v16.13.1-darwin-x64.tar.gz'],
      workingDirectory: dir.path);
  return '$nodeDir/bin';
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
            double? attrDouble(Map<String, String> attributes, String attr) {
              final widthString = attributes[attr];
              return widthString == null
                  ? widthString as double?
                  : double.tryParse(widthString);
            }

            ImageRender customBase64ImageRender() =>
                (context, attributes, element) {
                  final decodedImage = base64
                      .decode(attributes['src']!.split("base64,")[1].trim());
                  precacheImage(
                    MemoryImage(decodedImage),
                    context.buildContext,
                    onError: (exception, StackTrace? stackTrace) {
                      context.parser.onImageError!.call(exception, stackTrace);
                    },
                  );
                  return Image.memory(
                    decodedImage,
                    fit: BoxFit.fitWidth,
                    width: attrDouble(attributes, 'width'),
                    height: attrDouble(attributes, 'height'),
                    frameBuilder: (ctx, child, frame, _) {
                      if (frame == null) {
                        return Text(attributes['alt'] ?? "",
                            style: context.style.generateTextStyle());
                      }
                      return child;
                    },
                  );
                };
            return Html(
              data: data["html"],
              customImageRenders: {
                dataUriMatcher(): customBase64ImageRender(),
              },
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
