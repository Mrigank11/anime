from anime_downloader import get_anime_class
import json
import logging

logging.basicConfig(
    level=logging.DEBUG
)
logger = logging.getLogger('urllib3.connectionpool')
logger.setLevel(logging.WARNING)

NineAnime = get_anime_class("9anime")


def search(query):
    res = NineAnime.search(query)
    serialized = [{'title': x.title, 'url': x.url,
                   'meta': x.meta, 'poster': x.poster} for x in res]
    return json.dumps(serialized)


# search("fullmetal")

def get_stream_url(url, i):
    try:
        anime = NineAnime(url)
        url = anime[i].source().stream_url
        return url
    except Exception as e:
        print(e)
        return "error"


# print(get_stream_url('https://www8.9anime.is/watch/fullmetal-alchemist-dub.2wn0', 0))
