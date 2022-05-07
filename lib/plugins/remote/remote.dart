import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:public_tools/pigeon/instance.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/plugin.dart';
import '../../core/plugin_command.dart';
import '../../html_render/render.dart';
import '../../pigeon/app.dart';
import '../../utils/logger.dart';
import 'runtime.dart';
import 'server.dart';

late RemotePluginServer _server;
GlobalKey<HTMLRuntimeState> _previewKey = GlobalKey<HTMLRuntimeState>();

PluginCommand _createCommandItem(element) {
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

      return SingleChildScrollView(
        child: HTMLRuntime(
          data['html'],
          key: _previewKey,
          onEvent: (handlerName, eventData) {
            _server.invoke('event', {
              'event': 'domEvent',
              'handlerName': handlerName,
              'eventData': eventData,
            });
          },
        ),
      );
    },
  );
  return command;
}

void _updateCommands(Map<String, dynamic> data) {
  remotePlugin.commands = data["commands"].map<PluginCommand>((element) {
    return _createCommandItem(element);
  }).toList();
}

void _bindServerListener() async {
  _server.on('toast', (data) {
    showToast(data["content"]);
  });
  _server.on('hideApp', (data) async {
    await platformService.hideApp();
  });
  _server.on('showApp', (data) async {
    await windowManager.show();
  });
  _server.on('updateCommands', (data) {
    _updateCommands(data);
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
  _server.on('updatePreview', (data) {
    if (data['html'] != null) {
      _previewKey.currentState?.updateHTML(data['html']!);
    }
  });
}

void _onRegistery() {
  if (Platform.environment['REMOTE_PLUGIN_MODE'] != 'debug') {
    startRemote();
  }
  _server = RemotePluginServer(
    onDisconnect: () {
      remotePlugin.commands = [];
    },
    onReady: () async {
      final data = await _server.invoke("getCommands", {});
      logger.i('getCommands: $data');
      _updateCommands(data);
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
