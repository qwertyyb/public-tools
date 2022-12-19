import 'package:flutter/widgets.dart';

class ResultPreview extends StatefulWidget {
  final Widget? preview;

  ResultPreview(this.preview);

  @override
  State<StatefulWidget> createState() {
    return _ResultPreviewState();
  }
}

class _ResultPreviewState extends State<ResultPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.zero,
      color: Color.fromARGB(49, 165, 165, 165),
      child: SizedBox(
        child: this.widget.preview,
      ),
    );
  }
}
