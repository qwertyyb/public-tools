import 'dart:async';
import 'dart:convert';
import 'dart:io';

class MessageData {
  String type;
  dynamic payload;

  MessageData({this.type, this.payload});

  MessageData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    payload = json['payload'];
  }
}

void Function(dynamic) _createHandler(WebSocket socket) {
  return (dynamic data) {
    final message = MessageData.fromJson(data);
    print(data);
    socket.add(jsonEncode(data));
  };
}

void runServer() async {
  var server = await HttpServer.bind('127.0.0.1', 4040);
  server.listen((HttpRequest req) async {
    if (req.uri.path == '/ws') {
      var socket = await WebSocketTransformer.upgrade(req);
      socket.map((string) => jsonDecode(string)).listen(_createHandler(socket));
    }
  });
}
