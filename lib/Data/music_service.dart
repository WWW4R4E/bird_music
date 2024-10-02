import 'package:http/http.dart' as http;
import 'dart:convert';

// MusicService类提供与音乐相关的服务，包括通过艺术家名称搜索歌曲ID和获取歌曲信息
class MusicService {
  // 通过搜索查询和艺术家名称获取歌曲ID的方法
  Future<int?> getSongIdByArtist(String searchQuery, String artistName) async {
    String url =
        "http://music.163.com/api/search/get/web?csrf_token=&s=$searchQuery&type=1&offset=0&total=true&limit=20";
    var response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    int? songId;

    for (var song in data['result']['songs']) {
      for (var artist in song['artists']) {
        if (artist['name'] == artistName) {
          songId = song['id'];
          return songId;
        }
      }
    }
    return songId;
  }

  // 通过歌曲ID获取歌曲信息的方法，包括图片URL和歌词
  Future<(String?, String)> getSongInfo(
      String searchQuery, String artistName) async {
    // 获取歌曲ID
    int? songId = await getSongIdByArtist(searchQuery, artistName);

    if (songId == null) {
      return (null, '暂无歌词');
    }

    String songDetailUrl =
        "http://music.163.com/api/song/detail/?id=$songId&ids=[$songId]";
    var songDetailResponse = await http.get(Uri.parse(songDetailUrl));
    var songDetailData = jsonDecode(songDetailResponse.body);

    String lyricUrl =
        "https://music.163.com/api/song/lyric/?id=$songId&lv=-1&kv=-1&tv=-1";
    var lyricResponse = await http.get(Uri.parse(lyricUrl));
    var lyricData = jsonDecode(lyricResponse.body);

    if (songDetailData['code'] == 200 && lyricData['code'] == 200) {
      String picUrl = songDetailData['songs'][0]['album']['picUrl'] + '?param=1080y1080';
      String lyric = lyricData['lrc']['lyric'] ?? '暂无歌词';
      // debugPrint(picUrl);
      return (picUrl, lyric);
    } else {
      return (null, '暂无歌词');
    }
  }
}
