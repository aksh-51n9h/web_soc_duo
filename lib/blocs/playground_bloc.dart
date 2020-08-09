import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:websoc_duo/blocs/bloc.dart';
import 'package:websoc_duo/models/dot_point.dart';
import 'package:websoc_duo/service/websocket_client_api.dart';
import 'package:websoc_duo/service/websocket_client_mobile.dart';

class PlaygroundBloc implements Bloc {
  List<DotPoint> _pointList = [];
  final BuildContext _context;

  WebSocketClientApi _webSocketClientApi;

  final _pointListController = StreamController<DotPoint>.broadcast();

  StreamSink<DotPoint> get _updateList => _pointListController.sink;

  Stream<DotPoint> get pointList => _pointListController.stream;

  PlaygroundBloc(BuildContext context) : _context = context {
    _addListeners();
  }

  void _addListeners() {
    _webSocketClientApi = WebSocketClientApi();
    Future.delayed(const Duration(milliseconds: 800)).then((value) {
      _webSocketClientApi.getPointList().listen((event) {
        var point = event;
        point.position += Offset(0, MediaQuery.of(_context).size.height);

        Size size = MediaQuery.of(_context).size;

        double widthRatio = 0.0;

        widthRatio = max<double>(point.screenSize.width, size.width) /
            min<double>(point.screenSize.width, size.width);

        if (point.screenSize.width > size.width) {
          point.position = point.position.scale(1 / widthRatio, 1);
        } else {
          point.position = point.position.scale(widthRatio, 1);
        }

        // print(widthRatio);

        _pointList.add(point);
      });
    });
  }

  List<DotPoint> get points => _pointList;

  void addPoint(DotPoint point) {
    _pointList.add(point);
  }

  void sendPoint(DotPoint point) {
    _webSocketClientApi.sendPointToOtherClient(point);
  }

  @override
  void dispose() {
    _pointListController.close();
  }
}
