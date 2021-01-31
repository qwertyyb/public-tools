import 'package:flutter/material.dart';
import '../models/PasteItem.dart';

class PasteItemViewHeader extends StatelessWidget {
  PasteItemViewHeader({Key key, this.title}) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).primaryTextTheme.headline6),
          Spacer(),
          IconButton(
            icon: Icon(Icons.assessment_rounded,
                color: Theme.of(context).primaryIconTheme.color),
            onPressed: () {},
          ),
          IconButton(
              icon: Icon(Icons.delete_forever,
                  color: Theme.of(context).primaryIconTheme.color),
              onPressed: () {}),
        ],
      ),
    );
  }
}

class PasteItemView extends StatelessWidget {
  PasteItemView({Key key, this.pasteItem}) : super(key: key);
  final PasteItem pasteItem;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasteItemViewHeader(title: '此处是标题'),
          Container(
            height: 160,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                pasteItem.summary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
