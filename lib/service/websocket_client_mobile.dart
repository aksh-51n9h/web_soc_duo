import 'dart:convert';
import 'dart:io';

import 'package:websoc_duo/models/dot_point.dart';
import 'package:websoc_duo/server/transformer.dart';
import 'package:websoc_duo/service/websocket_client_api.dart';

class WebSocketMobileClientService
    with Transfomer
    implements WebSocketClientApi {
  WebSocket _webSocket;

  WebSocketMobileClientService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _connectToWebSocket();
  }

  Future<void> _connectToWebSocket() async {
    _webSocket = await WebSocket.connect("ws://192.168.1.169:4042");
  }

  @override
  Stream<DotPoint> getPointList() {
    return _webSocket.map((snapshot) {
      return DotPoint.fromJson(jsonDecode(snapshot) as Map);
    });
  }

  @override
  void dispose() {
    _webSocket.close();
  }

  @override
  void updatePointList(List<DotPoint> pointList) {
    String json = jsonEncode(pointList);

    _webSocket.add(json);
  }

  @override
  void sendPointToOtherClient(DotPoint dotPoint) {
    _webSocket.add(dotPoint.toJson());
  }
}

WebSocketClientApi getWebSocketClientApi() => WebSocketMobileClientService();
