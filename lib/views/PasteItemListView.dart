import 'package:flutter/material.dart';
import '../models/PasteItem.dart';
import './PasteItemView.dart';
import '../controllers/HistoryController.dart';

class PasteItemListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PasteItemListState();
}

class _PasteItemListState extends State<PasteItemListView> {
  final HistoryController _history = HistoryController();
  List<PasteItem> _list = [
    PasteItem(
        contentType: ContentType.text,
        summary: "hello world",
        updatedAt: DateTime.now())
  ];

  _PasteItemListState() {
    _history.onChange = _onHistoryChange;
  }

  void _onHistoryChange() async {
    var newList = await _history.refresh();
    setState(() {
      _list = newList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 500,
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (BuildContext context, int index) {
              return PasteItemView(pasteItem: _list[index]);
            },
          )
        ),
        Text("hello")
      ]
    );
  }
}
