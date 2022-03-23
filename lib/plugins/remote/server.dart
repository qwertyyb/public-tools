import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:oktoast/oktoast.dart';
import 'package:public_tools/core/plugin.dart';
import 'package:public_tools/pigeon/app.dart';
import 'package:public_tools/utils/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

typedef void ListReceiver(List<BaseListItem> list);
typedef void EnterItemReceiver();

List<WebSocket> sockets = [];
List<ListReceiver> receivers = [];
List<EnterItemReceiver> enterItemReceivers = [];
void Function(String content) setResultItemPreview = (content) => null;
String _binPath = '';

class MessageData {
  String type;
  Map<String, dynamic> payload;
  int time;
  String id;
  String replyId;

  MessageData({this.type, this.payload})
      : time = DateTime.now().millisecondsSinceEpoch,
        id = Uuid().v4(),
        replyId = Uuid().v4();

  MessageData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    payload = json['payload'];
    time = json['time'];
    id = json['id'];
    replyId = json['replayId'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['payload'] = this.payload;
    data['id'] = this.id;
    data['replyId'] = this.replyId;
    data['time'] = this.time;
    return data;
  }
}

String makeMessageData(String type, Map<String, dynamic> payload) {
  return jsonEncode(MessageData(type: type, payload: payload).toJson());
}

void Function(dynamic) _createHandler(WebSocket socket) {
  return (dynamic data) async {
    final message = MessageData.fromJson(data);
    logger.i(message.toJson());
    if (message.type == 'list') {
      List<BaseListItem> list = message.payload["list"]
          .map<BaseListItem>((e) => BaseListItem.fromJson(e))
          .toList();
      receivers.forEach((element) {
        element(list);
      });
    } else if (message.type == 'enter') {
      final enterItemReceiver = enterItemReceivers.first;
      if (enterItemReceiver != null) {
        enterItemReceiver();
      }
    } else if (message.type == 'toast') {
      showToast(message.payload["content"]);
    } else if (message.type == 'hideApp') {
      await Service().hideApp();
    } else if (message.type == 'showApp') {
      await windowManager.show();
    } else if (message.type == 'preview') {
      setResultItemPreview(message.payload['html']);
    }
    // socket.add(jsonEncode(data));
  };
}

class RemotePluginServer {
  HttpServer _server;
  WebSocket _socket;
  final Function onReady;
  Map<String, StreamController<MessageData>> _messages = {};

  RemotePluginServer({this.onReady}) {
    this._init();
  }

  void _init() async {
    this._server = await HttpServer.bind('127.0.0.1', 4040);
    this._server.listen((HttpRequest req) async {
      if (req.uri.path != '/ws' || this._socket != null) {
        return;
      }
      logger.i('新的socket已连接');
      var socket = await WebSocketTransformer.upgrade(req);
      socket.map((string) => jsonDecode(string)).listen(_onMessage, onDone: () {
        socket.close();
        this._socket = null;
        runClient();
      });
      this._socket = socket;
      this.onReady();
    });
  }

  void _onMessage(dynamic data) async {
    final message = MessageData.fromJson(data);
    logger.i('收到消息: ${message.toJson()}');
    if (_messages[message.id] != null) {
      _messages[message.id].add(message);
      _messages[message.id].close();
      _messages.remove(message.id);
    }
    if (message.type == 'toast') {
      showToast(message.payload["content"]);
    } else if (message.type == 'hideApp') {
      await Service().hideApp();
    } else if (message.type == 'showApp') {
      await windowManager.show();
    } else if (message.type == 'preview') {
      setResultItemPreview(message.payload['html']);
    }
  }

  Future invoke(String action, Map<String, dynamic> payload) async {
    assert(_server != null);
    assert(_socket != null);
    final message = MessageData(type: action, payload: payload);
    // ignore: close_sinks
    final streamController = StreamController<MessageData>();
    _messages[message.replyId] = streamController;
    /* Future.delayed(Duration(seconds: 5), () {
      if (_messages[message.replyId] != null) {
        _messages[message.replyId]
            .add(MessageData(type: 'error', payload: {'message': 'timeout'}));
        _messages[message.replyId].close();
        _messages.remove(message.replyId);
      }
    }); */
    _socket.add(json.encode(message));
    final result = await streamController.stream.first;
    if (result.type == 'error') {
      throw Exception(result.payload['message']);
    }
    _messages.remove(message.time);
    return result.payload;
  }
}

void setBinPath(String binPath) {
  _binPath = binPath;
}

void runClient() async {
  var pluginDir = '';
  if (Platform.environment["REMOTE_PLUGIN_MODE"] == 'local') {
    pluginDir = Directory.current.path + '/plugins';
  }
  // @todo 生产环境下载并执行
  if (pluginDir == '') return null;
  final clientProcess = await Process.start(
    '$_binPath/npm',
    ['run', 'start'],
    workingDirectory: pluginDir,
  );
  clientProcess.stdout.transform(utf8.decoder).forEach(print);
}

void send([String type, Map<String, dynamic> payload = const {}]) {
  sockets.forEach((element) {
    element.add(makeMessageData(type, payload));
  });
}

void onUpdateList(ListReceiver receiver) {
  receivers.add(receiver);
}
