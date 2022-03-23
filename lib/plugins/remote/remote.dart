import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/utils/logger.dart';

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

class RemotePlugin extends Plugin {
  RemotePluginServer _server;
  List<PluginCommand> commands = [];
  RemotePlugin() {
    _downloadNodeJs().then((binPath) {
      setBinPath(binPath);
      runClient();
    });
    this._server = RemotePluginServer(onReady: () async {
      final data = await this._server.invoke("getCommands", {});
      logger.i('getCommands: $data');
      this.commands = data["commands"]
          .map<PluginCommand>((element) => PluginCommand.fromJson(element))
          .toList();
    });
    logger.i('server is running');
  }

  @override
  void onEnter(PluginCommand command) {
    this._server.invoke("onEnter", {
      "command": command.toJson(),
    });
  }

  @override
  Future<List<SearchResult>> onSearch(
      String keyword, PluginCommand command) async {
    final data = await this
        ._server
        .invoke('onSearch', {"keyword": keyword, "command": command.toJson()});
    return data["results"]
        .map<SearchResult>((element) => SearchResult.fromJson(element))
        .toList();
  }

  @override
  void onResultTap(SearchResult result) {
    this._server.invoke('onResultTap', {
      "result": result.toJson(),
    });
  }

  @override
  Future<Widget> onResultSelected(SearchResult result) async {
    final data = await this._server.invoke('onResultSelected', {
      "result": result.toJson(),
    });
    if (data["html"] == null) return null;
    double attrDouble(Map<String, String> attributes, String attr) {
      final widthString = attributes[attr];
      return widthString == null
          ? widthString as double
          : double.tryParse(widthString);
    }

    ImageRender customBase64ImageRender() => (context, attributes, element) {
          final decodedImage =
              base64.decode(attributes['src'].split("base64,")[1].trim());
          precacheImage(
            MemoryImage(decodedImage),
            context.buildContext,
            onError: (exception, StackTrace stackTrace) {
              context.parser.onImageError.call(exception, stackTrace);
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
  }

  @override
  void onExit(PluginCommand command) {
    this._server.invoke("onExit", {
      "command": command.toJson(),
    });
  }
}
