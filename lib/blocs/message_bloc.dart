import 'dart:async';

import 'dart:io';

class MessageBloc {
  WebSocket _webSocket;

  final messageBlocController = StreamController<String>.broadcast();

  Stream<String> get messageList => messageBlocController.stream;

  StreamSink<String> get newMessage => messageBlocController.sink;

  MessageBloc() {
    _initialize();
  }

  void _initialize() async {
    await _connectToWebsocket();

    if (_webSocket != null) {
      _webSocket.listen(
        (event) {
          if (event is String) {
            newMessage.add(event);
          }
        },
      );
    }
  }

  Future<void> _connectToWebsocket() async {
    try {
      _webSocket = await WebSocket.connect("ws://192.168.1.169:4042");
    } on WebSocketException catch (error) {
      print(error);
    }
  }

  void addNewMessage() {
    String randomText = "Hello World!";

    _webSocket.add(randomText);
  }

  void dispose() {
    messageBlocController.close();
  }
}
