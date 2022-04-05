import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'custom_render.dart';

class HTMLRender extends StatelessWidget {
  final String html;
  final InvokeDomEvent? onEvent;
  final Key uniqueKey = UniqueKey();

  HTMLRender({required this.html, this.onEvent});

  @override
  Widget build(BuildContext context) {
    CustomRenderMatcher isFlutterContainer =
        (context) => context.tree.element?.localName == 'flutter-container';

    CustomRender flutterContainerRender =
        CustomRender.widget(widget: (RenderContext context, buildChildren) {
      final widget =
          renderNodes(context.tree.element!.nodes, (handlerName, eventData) {
        onEvent?.call(handlerName, eventData);
      }).firstOrNull;
      if (widget == null) return Text('no child');
      return widget;
    });
    return Html(
      key: uniqueKey,
      data: html,
      customRenders: {
        isFlutterContainer: flutterContainerRender,
      },
      tagsList: Html.tags..addAll(['flutter-container']),
    );
  }
}
