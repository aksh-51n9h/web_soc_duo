import 'dart:convert';
import 'dart:html';

import 'package:websoc_duo/models/dot_point.dart';
import 'package:websoc_duo/service/websocket_client_api.dart';

class WebSocketClientWebService implements WebSocketClientApi {
  WebSocket _webSocket;

  WebSocketClientWebService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _connectToWebSocket();
  }

  Future<void> _connectToWebSocket() async {
    _webSocket = WebSocket("ws://127.0.0.1:4042");
  }

  @override
  Stream<DotPoint> getPointList() {
    return _webSocket.onMessage.map((snapshot) {
      return DotPoint.fromJson(jsonDecode(snapshot.data) as Map);
    });
  }

  @override
  void dispose() {
    _webSocket.close();
  }

  @override
  void updatePointList(List<DotPoint> pointList) {
    String json = jsonEncode(pointList);

    _webSocket.send(json);
  }

  @override
  void sendPointToOtherClient(DotPoint dotPoint) {
    _webSocket.send(dotPoint.toJson());
  }
}

WebSocketClientApi getWebSocketClientApi() => WebSocketClientWebService();
