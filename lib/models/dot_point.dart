import 'dart:convert';

import 'package:flutter/material.dart';

class DotPoint {
  String id;
  Offset position;
  Offset velocity;
  Size screenSize;
  bool isTransferred;
  int color;

  DotPoint({
    this.id,
    this.position,
    this.velocity,
    this.color,
    this.isTransferred,
    this.screenSize,
  }) {
    id = DateTime.now().toIso8601String();
  }

  factory DotPoint.fromJson(dynamic doc) {
    // print(doc['position_dx'].runtimeType);
    var position = Offset(doc['position_dx'] * 1.0, doc['position_dy'] * 1.0);

    var velocity = Offset(doc['velocity_dx'] * 1.0, doc['velocity_dy'] * 1.0);

    var screenSize = Size(doc['width'] * 1.0, doc['height'] * 1.0);

    return DotPoint(
        id: doc['id'],
        position: position,
        velocity: velocity,
        color: doc['color'],
        isTransferred: doc['is_transferred'],
        screenSize: screenSize);
  }

  String toJson() {
    Map pointJson = {
      'id': id,
      'position_dx': position.dx,
      'position_dy': position.dy,
      'velocity_dx': velocity.dx,
      'velocity_dy': velocity.dy,
      'is_transferred': isTransferred,
      'color': color,
      'width': screenSize.width,
      'height': screenSize.height
    };

    return jsonEncode(pointJson);
  }
}
