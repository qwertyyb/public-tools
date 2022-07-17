import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WebviewPreview extends StatefulWidget {
  final String? url;
  final String? html;

  WebviewPreview({this.url, this.html});

  @override
  State<StatefulWidget> createState() {
    return _WebviewPreviewState();
  }
}

class _WebviewPreviewState extends State<WebviewPreview> {
  GlobalKey _key = GlobalKey();
  MethodChannel channel = MethodChannel("webview");

  void updateWebviewRect(Map<String, double> rect) {
    channel.invokeMethod("setRect", rect);
  }

  @override
  void initState() {
    if (this.widget.url != null) {
      channel.invokeMethod("setUrl", this.widget.url!);
    } else if (this.widget.html != null) {
      channel.invokeMethod("setHTML", this.widget.html);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WebviewPreview oldWidget) {
    if (this.widget.url != null) {
      channel.invokeMethod("setUrl", this.widget.url!);
    } else if (this.widget.html != null) {
      channel.invokeMethod("setHTML", this.widget.html);
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
