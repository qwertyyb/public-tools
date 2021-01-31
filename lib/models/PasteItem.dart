enum ContentType { text, image }

class PasteItem {
  String summary;
  DateTime updatedAt;
  ContentType contentType;

  PasteItem({this.summary, this.updatedAt, this.contentType});
}
