import 'package:flutter/material.dart';
import 'package:ypaste_flutter/controllers/ClipboardController.dart';
import 'package:ypaste_flutter/controllers/HistoryController.dart';
import '../models/PasteItem.dart';
import 'package:intl/intl.dart';

class PasteItemViewHeader extends StatelessWidget {
  PasteItemViewHeader(
      {Key key,
      this.title,
      this.subTitle,
      this.onCopyBtnPressed,
      this.onDeleteBtnPressed})
      : super(key: key);

  final String title;
  final String subTitle;
  final void Function() onCopyBtnPressed;
  final void Function() onDeleteBtnPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).primaryTextTheme.subtitle1),
            Text(subTitle, style: Theme.of(context).primaryTextTheme.caption)
          ]),
          Spacer(),
          IconButton(
            tooltip: '复制',
            icon: Icon(Icons.content_copy,
                color: Theme.of(context).primaryIconTheme.color),
            onPressed: onCopyBtnPressed,
          ),
          IconButton(
            tooltip: '删除',
            icon: Icon(Icons.delete_forever,
                color: Theme.of(context).primaryIconTheme.color),
            onPressed: onDeleteBtnPressed,
          ),
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
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasteItemViewHeader(
              title: pasteItem.contentType == ContentType.text ? '文本' : '图片',
              subTitle:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(pasteItem.updatedAt),
              onCopyBtnPressed: () {
                ClipboardController.writeText(pasteItem.text);
              },
              onDeleteBtnPressed: () {
                HistoryController.instance.deleteItem(pasteItem.id);
              }),
          Container(
            height: 160,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                pasteItem.text,
              ),
            ),
          )
        ],
      ),
    );
  }
}
