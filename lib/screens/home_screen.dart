import 'dart:io';

import 'package:flutter/material.dart';
import 'package:websoc_duo/blocs/message_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MessageBloc _messageBloc;
  @override
  void initState() {
    super.initState();
    _messageBloc = MessageBloc();
  }

  @override
  void dispose() {
    _messageBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<String>(
          stream: _messageBloc.messageList,
          initialData: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              child: Center(child: Text('${snapshot.data}')),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _messageBloc.addNewMessage,
        child: Icon(Icons.settings_input_component),
      ),
    );
  }
}
