import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/core/plugin_result_item.dart';
import 'package:public_tools/utils/logger.dart';

import 'server.dart';

class RemotePlugin extends Plugin<String> {
  RemotePlugin() {
    runServer();
    logger.i('server is running');
  }

  @override
  void onQuery(String keyword,
      void Function(List<PluginListItem<String>> list) setResult) {
    receivers.clear();
    enterItemReceivers.clear();
    setResultItemPreview = (content) {};
    onUpdateList(setResult);
    send("keyword", {"keyword": keyword});
  }

  @override
  onTap(PluginListItem<String> item, {enterItem}) {
    enterItemReceivers.clear();
    enterItemReceivers.add(enterItem);
    setResultItemPreview = (content) {};
    send("tap", {'item': item});
  }

  @override
  void onSearch(String keyword,
      void Function(List<PluginListItem<String>> list) setResult) {
    receivers.clear();
    enterItemReceivers.clear();
    setResultItemPreview = (content) {};
    setLoading(true);
    onUpdateList(setResult);
    onUpdateList((list) {
      setLoading(false);
    });
    send("keyword", {"keyword": keyword});
  }

  @override
  void onResultTap(PluginListItem<String> item) {
    enterItemReceivers.clear();
    send("tap", {'item': item});
  }

  @override
  void onResultSelect(PluginListItem<String> item, {setPreview}) {
    setResultItemPreview = (content) {
      if (content == '' || content == null) {
        return setPreview(null);
      }
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
      setPreview(Html(
        data: content,
        customImageRenders: {
          dataUriMatcher(): customBase64ImageRender(),
        },
      ));
    };
    send('select', {'item': item});
  }

  @override
  void onExit(PluginListItem item) {
    send("exit", {});
    super.onExit(item);
  }
}
