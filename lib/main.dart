import 'package:animedl/ui/home.dart';
import 'package:flutter/material.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: AppBar(title: Text("AnimeDL")),
        body: Home(),
      ),
    );
  }
}
