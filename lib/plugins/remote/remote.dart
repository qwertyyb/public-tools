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
            CustomRenderMatcher isTextButton =
                (context) => context.tree.element?.localName == 'text-button';
            CustomRender textButtonRender = CustomRender.widget(
                widget: (RenderContext context, buildChildren) {
              return TextButton(
                child: Text(context.tree.element?.text ?? ''),
                onPressed: () {
                  _server.invoke('onTextButtonPressed', {
                    "command": element,
                    "result": result.toJson(),
                  });
                },
              );
            });
            return Html(
              data: data["html"],
              anchorKey: GlobalKey(),
              customRenders: {isTextButton: textButtonRender},
              tagsList: Html.tags..addAll(['text-button']),
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
