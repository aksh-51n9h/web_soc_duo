import 'dart:convert';
import 'dart:io';

void main() async {
  var server = WebSocDuoServer(address: '0.0.0.0', port: 4042);
  await server.openServer();

  print('1. check connections');

  stdin.transform(Utf8Decoder()).transform(LineSplitter()).listen(
    (event) {
      if (event.compareTo("close") == 0) {
        print("Closing server...");
        server.dispose();
        exit(0);
      } else {
        var ch = int.parse(event);

        switch (ch) {
          case 1:
            server.checkConnection();
            break;
          default:
            print('Invalid choice...');
        }
      }
    },
  );
}

class WebSocDuoServer {
  final String address;
  final int port;
  HttpServer _server;
  WebSocket _webSocket;
  Map<String, WebSocket> _connectionList = {};
  Map<String, List<DotPointServer>> _pointList = {};
  Map<String, List<DotPointServer>> _transferList = {};
  int _count = 0;

  WebSocDuoServer({this.address, this.port})
      : assert(address != null, port != null);

  Future<void> openServer() async {
    await _initialize();
  }

  Future<void> _initialize() async {
    _server = await _createServer(address, port);

    print("Server started at : ${_server.address}:${_server.port}");

    _addListener();
  }

  void _addListener() {
    print("Adding request listener to server...");

    _server.listen(
      (HttpRequest request) {
        var remoteAddress = request.connectionInfo.remoteAddress.address;

        _upgradeToWebSocket(request).then(
          (webSocket) {
            _webSocket = webSocket;
            _addConnection(remoteAddress, webSocket);
          },
          onError: (error) {
            print(
                "Error has ocuured while upgrading to websocket. ERROR : $error");
          },
        );
      },
      onDone: () {
        print("Sever listener deattached...");
      },
      onError: (error) {
        print("Error has occurred!. ERROR : $error");
      },
    );

    print("Listener added to the server...");
  }

  void checkConnection() {
    _connectionList.forEach((remoteAddress, webSocket) {
      print('$remoteAddress : ${webSocket.readyState == WebSocket.open}');
    });
  }

  void _addConnection(String remoteAddress, WebSocket webSocket) {
    print('Adding connections to the connectionList...');

    if (_connectionList.isEmpty ||
        !_connectionList.keys.contains(remoteAddress)) {
      _connectionList[remoteAddress] = webSocket;

      print('$remoteAddress added to the connectionList...');

      _pointList[remoteAddress] = <DotPointServer>[];
      _transferList[remoteAddress] = <DotPointServer>[];

      _addListenerToWebSocket(remoteAddress);
    }
  }

  void _addListenerToWebSocket(String remoteAddress) {
    print("Adding request listener to websocket...");

    _webSocket.listen(
      (dynamic data) {
        if (data is String) {
          print(data);
          _connectionList.keys.forEach(
            (element) {
              if (element.compareTo(remoteAddress) != 0) {
                print('sending to $element');
                _connectionList[element].add(data);
              }
            },
          );
        }
      },
      onDone: () {
        print("Websocket listener deattached...");
        _connectionList.remove(remoteAddress);
      },
      onError: (error) {
        print("Error has occurred!. ERROR : $error");
      },
    );

    print("Listener added to the websocket...");
  }

  Future<WebSocket> _upgradeToWebSocket(HttpRequest request) async {
    print(
        "Upgrading request from ${request.connectionInfo.remoteAddress.address} to websocket...");

    return WebSocketTransformer.upgrade(request);
  }

  Future<HttpServer> _createServer(String address, int port) {
    print('Creating server...');
    return HttpServer.bind(address, port);
  }

  void dispose() {
    if (_server != null) {
      _server.close();
    }

    if (_webSocket != null) {
      _webSocket.close();
    }
  }

  List<DotPointServer> toPointList(List<dynamic> jsonList) {
    List<DotPointServer> _convertedList = jsonList
        .map((e) => DotPointServer.fromDoc(jsonDecode(e) as Map))
        .toList();

    return _convertedList;
  }
}

class PointDatabase implements PointDatabaseApi {
  List<String> _pointList = [];

  @override
  void addPoint(String pointData) {
    _pointList.add(pointData);
  }

  @override
  void removePoint(String pointData) {
    _pointList.remove(pointData);
  }

  @override
  void showData() {
    for (var pointData in _pointList) {
      print(pointData);
    }
  }
}

abstract class PointDatabaseApi {
  void addPoint(String pointData);

  void removePoint(String pointData);

  void showData();
}

class DotPointServer {
  String id;
  double position_dx;
  double position_dy;
  double velocity_dx;
  double velocity_dy;
  int color;

  DotPointServer({
    this.id,
    this.position_dx,
    this.position_dy,
    this.velocity_dx,
    this.velocity_dy,
    this.color,
  });

  factory DotPointServer.fromDoc(dynamic doc) {
    return DotPointServer(
      id: doc['id'],
      position_dx: doc['position_dx'] * 1.0,
      position_dy: doc['position_dy'] * 1.0,
      velocity_dx: doc['velocity_dx'] * 1.0,
      velocity_dy: doc['velocity_dy'] * 1.0,
      color: doc['color'],
    );
  }

  String toJson() {
    var json = {
      'id': id,
      'position_dx': position_dx,
      'position_dy': position_dy,
      'velocity_dx': velocity_dx,
      'velocity_dy': velocity_dy,
      'color': color,
    };

    return jsonEncode(json);
  }

  bool areSame(DotPointServer other) => this.id.compareTo(other.id) == 0;
}
