import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:websoc_duo/blocs/playground_bloc.dart';
import 'package:websoc_duo/models/dot_point.dart';

class Playground extends StatefulWidget {
  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  PlaygroundBloc _playgroundBloc;

  @override
  void initState() {
    super.initState();

    _playgroundBloc = PlaygroundBloc(context);

    Timer.periodic(const Duration(milliseconds: 10), (tick) {
      if (_playgroundBloc.points.length > 0) {
        setState(
          () {},
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    _calculateNewPositions();

    return GestureDetector(
      onTapDown: (TapDownDetails tapDownDetails) {
        var point = DotPoint(
          position: tapDownDetails.globalPosition,
          velocity: Offset(0, -0.8 + Random().nextDouble() * 1.8 * -1),
          color: getColorHexValue(),
          screenSize: MediaQuery.of(context).size,
          isTransferred: false,
        );
        _playgroundBloc.addPoint(point);
      },
      child: CustomPaint(
        painter: ScreenPainter(pointList: [..._playgroundBloc.points]),
        child: Container(),
      ),
    );
  }

  void _calculateNewPositions() {
    for (int index = 0; index < _playgroundBloc.points.length; index++) {
      final DotPoint point = _playgroundBloc.points[index];

      if (point != null && point.position.dx > 0 && point.position.dy > 0) {
        point.position += point.velocity;
      } else if (!point.isTransferred) {
        point.isTransferred = true;
        _playgroundBloc.sendPoint(point);
      }
    }
  }

  int getColorHexValue() {
    var colors = [];

    Colors.primaries.forEach((element) {
      colors.add(element.value);
    });

    return colors[Random().nextInt(colors.length)];
  }
}

class ScreenPainter extends CustomPainter {
  final List<DotPoint> pointList;

  ScreenPainter({this.pointList});

  @override
  void paint(Canvas canvas, Size size) {
    Rect background = Rect.fromLTWH(0, 0, size.width, size.height);
    Paint backgroundPainter = Paint()..color = Colors.black;

    canvas.drawRect(background, backgroundPainter);

    try {
      if (pointList.length > 0) {
        for (var point in pointList) {
          if (point.position.dx > 0 && point.position.dy > 0) {
            Paint circlePainter = Paint()..color = Color(point.color);
            canvas.drawCircle(point.position, 10.0, circlePainter);
          }
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
