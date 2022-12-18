import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef dynamic InvokeDomEvent(String handlerName, dynamic args);

class WebviewPreview extends StatefulWidget {
  final String? url;
  final String? html;
  final InvokeDomEvent? onEvent;

  WebviewPreview({this.url, this.html, this.onEvent, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebviewPreviewState();
  }
}

class WebviewPreviewState extends State<WebviewPreview> {
  GlobalKey _key = GlobalKey();
  MethodChannel channel = MethodChannel("webview");
  String? html;

  void updateWebviewRect(Map<String, double> rect) {
    channel.invokeMethod("setRect", rect);
  }

  void updateHTML(String html) {
    this.html = html;
    channel.invokeMethod("setHTML", this.html);
  }

  @override
  void initState() {
    this.html = this.widget.html;
    if (this.widget.url != null) {
      channel.invokeMethod("setUrl", this.widget.url!);
    } else if (this.html != null) {
      channel.invokeMethod("setHTML", this.html);
    }
    channel.setMethodCallHandler((call) async {
      return this.widget.onEvent?.call(call.method, call.arguments);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WebviewPreview oldWidget) {
    if (this.widget.url != null) {
      channel.invokeMethod("setUrl", this.widget.url!);
    } else if (this.html != null) {
      channel.invokeMethod("setHTML", this.html);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    channel.invokeMethod("hide");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: _key,
      child: LayoutBuilder(builder: (context, box) {
        Future.delayed(Duration.zero, () {
          final renderBox =
              _key.currentContext?.findRenderObject() as RenderBox?;
          print("renderBox: $renderBox");
          if (renderBox == null) return;
          final offset = renderBox.localToGlobal(Offset.zero);
          final bounds = renderBox.paintBounds;
          final rect = {
            "x": offset.dx,
            "y": offset.dy,
            "width": bounds.width,
            "height": bounds.height
          };
          print("rect: $rect");
          updateWebviewRect(rect);
        });
        return Container();
      }),
    );
  }
}
