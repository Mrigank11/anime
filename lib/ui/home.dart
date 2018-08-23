import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animedl/model/SearchResult.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const platform = const MethodChannel('kmrigank.animedl/search');
  TextEditingController _searchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSearchBar(),
        Expanded(
          child: _buildFutureBuilder(),
        )
      ],
    );
  }

  FutureBuilder<List<SearchResult>> _buildFutureBuilder() {
    return FutureBuilder(
      future: _searchAnime(_searchField.text),
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            List<SearchResult> results = snapshot.data;
            return _buildGridView(results);
          default:
            return Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }

  GridView _buildGridView(List<SearchResult> results) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 0.5),
      itemCount: results.length,
      itemBuilder: (_, i) {
        SearchResult result = results[i];
        return GridTile(
          child: _buildSearchResultCard(result),
        );
      },
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return GestureDetector(
      onTap: () => onSearchResultTap(result),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 180.0,
              child: CachedNetworkImage(
                imageUrl: result.poster,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                result.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
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
    );
  }

  void onSearchResultTap(result) {
    TextEditingController _epField = TextEditingController();
    AlertDialog loading = AlertDialog(
      content: Row(
        children: <Widget>[
          //TODO:remove this hack
          Expanded(
            child: Container(height: 40.0),
          ),
          CircularProgressIndicator(),
          Expanded(
            child: Container(height: 40.0),
          )
        ],
      ),
    );
    AlertDialog alertDialog = AlertDialog(
      title: Text("Enter episode no."),
      content: TextField(
        controller: _epField,
        keyboardType: TextInputType.number,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.check),
          onPressed: () async {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (_) => loading,
                barrierDismissible: false);
            String url =
                await _getStreamUrl(result.url, int.parse(_epField.text));
            Navigator.of(context).pop();
            if (await canLaunch(url)) {
              launch(url);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Failed"),
                  ));
            }
          },
        )
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  //TODO(refactor):use redux or ScopedModel
  Future<String> _getStreamUrl(String url, int ep) async {
    try {
      final String result =
          await platform.invokeMethod('getStreamUrl', {'url': url, 'ep': ep});
      return result;
    } on PlatformException {
      return "error";
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
    return null;
  }
}
