import 'package:flutter/material.dart';
import 'package:websoc_duo/screens/home_screen.dart';
import 'package:websoc_duo/screens/playground.dart';

void main() {
  runApp(WebSockDuo());
}

class WebSockDuo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.from(colorScheme: ColorScheme.dark()),
      home: Playground(),
    );
  }
}
