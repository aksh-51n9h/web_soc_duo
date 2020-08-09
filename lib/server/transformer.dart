import 'dart:async';
import 'dart:convert';

import 'package:websoc_duo/models/dot_point.dart';

class Transfomer {
  final stringToPointList =
      StreamTransformer<String, List<DotPoint>>.fromHandlers(
    handleData: (jsonData, sink) {
      List<dynamic> pointListJson = jsonDecode(jsonData);

      List<DotPoint> _convertedList = pointListJson
          .map((e) => DotPoint.fromJson(jsonDecode(e) as Map))
          .toList();

      sink.add(_convertedList);
    },
  );
}
