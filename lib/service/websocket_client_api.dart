import 'package:websoc_duo/models/dot_point.dart';

import 'websocket_client_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:websoc_duo/service/websocket_client_mobile.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:websoc_duo/service/websocket_client_web.dart';

abstract class WebSocketClientApi {
  Stream<DotPoint> getPointList();

  void updatePointList(List<DotPoint> pointList);

  void sendPointToOtherClient(DotPoint dotPoint);

  void dispose();

  factory WebSocketClientApi() => getWebSocketClientApi();
}
