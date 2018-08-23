class SearchResult {
  final String title, url, poster;
  final Map meta;

  SearchResult.fromMap(Map map)
      : title = map['title'],
        url = map['url'],
        poster = map['poster'],
        meta = map['meta'];
}
