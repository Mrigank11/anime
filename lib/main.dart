import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = const MethodChannel('kmrigank.animedl/search');
  TextEditingController _searchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: AppBar(title: Text("AnimeDL")),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchField,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _searchAnime(_searchField.text),
                builder: (context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      List<SearchResult> results = snapshot.data;
                      return ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (ctx, i) {
                            return ListTile(
                                onTap: () {
                                  TextEditingController _epField =
                                      TextEditingController();
                                  AlertDialog alertDialog = AlertDialog(
                                    title: Text("Enter episode no."),
                                    content: TextField(
                                      controller: _epField,
                                      keyboardType: TextInputType.number,
                                    ),
                                    actions: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _getStreamUrl(results[i].url,
                                              int.parse(_epField.text));
                                          Scaffold.of(ctx)
                                              .showSnackBar(SnackBar(
                                            content: Text("Wait..."),
                                          ));
                                        },
                                      )
                                    ],
                                  );
                                  showDialog(
                                      context: ctx,
                                      builder: (ctx) => alertDialog);
                                },
                                title: Text(results[i].title));
                          });
                    default:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> _getStreamUrl(String url, int ep) async {
    try {
      final String result =
          await platform.invokeMethod('getStreamUrl', {'url': url, 'ep': ep});
      launch(result);
    } on PlatformException {
      print("Error");
    }
  }

  Future<List<SearchResult>> _searchAnime(query) async {
    try {
      final String result =
          await platform.invokeMethod('searchAnime', {'query': query});
      List resultList = (json.decode(result) as List);
      List<SearchResult> results =
          resultList.map((f) => SearchResult.fromMap(f)).toList();
      return results;
    } on PlatformException {
      print("Error");
    }
  }
}

class SearchResult {
  final String title, url, poster;
  final Map meta;

  SearchResult.fromMap(Map map)
      : title = map['title'],
        url = map['url'],
        poster = map['poster'],
        meta = map['meta'];
}
