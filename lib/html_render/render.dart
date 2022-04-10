import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../utils/logger.dart';
import 'custom_render.dart';

class HTMLRuntime extends StatefulWidget {
  final InvokeDomEvent? onEvent;
  final String initialHtml;

  HTMLRuntime(this.initialHtml, {Key? key, this.onEvent}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HTMLRuntimeState();
  }
}

class HTMLRuntimeState extends State<HTMLRuntime> {
  String html = '';
  Key uniqueKey = UniqueKey();

  void updateHTML(String html) {
    logger.i('updatePreview: $html');
    setState(() {
      this.html = html;
      this.uniqueKey = UniqueKey();
    });
  }

  @override
  void didUpdateWidget(covariant HTMLRuntime oldWidget) {
    logger.i('didUpdate');
    if (this.widget.initialHtml != html) {
      this.html = this.widget.initialHtml;
      this.uniqueKey = UniqueKey();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    this.html = widget.initialHtml;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CustomRenderMatcher isFlutterContainer =
        (context) => context.tree.element?.localName == 'flutter-container';

    CustomRender flutterContainerRender =
        CustomRender.widget(widget: (RenderContext context, buildChildren) {
      final widget =
          renderNodes(context.tree.element!.nodes, (handlerName, eventData) {
        this.widget.onEvent?.call(handlerName, eventData);
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
