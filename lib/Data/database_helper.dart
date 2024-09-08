import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:bird_music/Data/music_service.dart';
import 'package:bird_music/Data/song_playlist.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Isar? _isarInstance;

  // 初始化Isar数据库实例
  static Future<Isar> initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    debugPrint(dir.path);
    _isarInstance = await Isar.open(
      [PlaylistSchema, SongSchema, Playlist_SongSchema],
      directory: dir.path,
    );
    final loacallist = Playlist()
      ..id = 1
      ..name = 'My Playlist';
    await _isarInstance!.writeTxn(() async {
      await _isarInstance!.playlists.put(loacallist);
    });
    return _isarInstance!;
  }

  // 添加歌曲到数据库
  static Future<void> addSong(String path) async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }

    final playlist = await _isarInstance!.playlists
        .filter()
        .nameEqualTo('My Playlist')
        .findFirst();
    if (playlist == null) {
      throw Exception('Playlist "My Playlist" not found');
    }
    final name = path.split('/').last.split('.').first;
    debugPrint("$name - $path");
    final musicServiceInstance = MusicService(); 
    (String?, String) info = await musicServiceInstance.getSongInfo(name.split(' - ').first, name.split(' - ').last); // 通过实例调用getSongInfo方法
    final songnum = Song()
      ..name = name
      ..path = path
      ..lyric = info.$2
      ..playlist.add(playlist);
    await _isarInstance!.writeTxn(() async {
      // 先将 songnum 添加到数据库中
      await _isarInstance!.songs.put(songnum);
    }

    // 再将 songnum 添加到播放列表中(未完成)
    
  );

    // 检查是否已经存在相同路径的歌曲
    final existingSongs =
        await _isarInstance!.songs.filter().pathEqualTo(path).findAll();
    if (existingSongs.isNotEmpty) {
      for (var song in existingSongs.sublist(1, existingSongs.length)) {
        final songId = song.id;
        debugPrint(songId.toString());
        await _isarInstance!.writeTxn(() async {
          await _isarInstance!.songs.delete(songId!);
        });
      }
    }
  }

  // 根据歌名搜索歌曲
  static Future<Map<String, dynamic>> searchSong(String name) async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }

    // 直接查找第一个匹配的歌曲
    final song = await _isarInstance!.songs.filter().nameEqualTo(name).findFirst();

    // 如果没有找到歌曲，返回空结果
    if (song == null) {
      return {'name': '', 'path': '', 'lyrics': ''};
    }

    // 返回找到的歌曲信息
    return {
      'name': song.name,
      'path': song.path,
      'lyric': song.lyric,
    };
  }

  // 获取歌词
  static Future<String> getLyrics(String name) async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }

    // 直接查找第一个匹配的歌曲
    final song = await _isarInstance!.songs.filter().nameEqualTo(name).findFirst();

    // 如果没有找到歌曲，返回空结果
    if (song == null) {
      return '';
    }

    // 返回找到的歌曲信息
    return song.lyric;
  }


  // 获取本地所有歌曲
  static Future<List<Map<String, dynamic>>> getLocalSongs() async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }
    final songs = await _isarInstance!.songs.where().findAll();
    return songs
        .map((song) => {
              'id': song.id,
              'name': song.name,
              'path': song.path, 
              'lyrics': song.lyric
            })
        .toList();
  }

  // 获取播放列表的所有歌曲
  static Future<List<Map<String, dynamic>>> getSongs() async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }
    final songs = await _isarInstance!.playlist_Songs.where().findAll();
    final filteredSongs = <Map<String, dynamic>>[];
    for (var song in songs) {
      filteredSongs.add({
        'name': song.name,
        'path': song.path,
      });
    }
    return filteredSongs;
  }


  // 清理播放列表
  static Future<void> cleanPlaylist() async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }

    try {
      final songIds = await _isarInstance!.playlist_Songs.where().idProperty().findAll();
      if (songIds.isNotEmpty) {
        await _isarInstance!.writeTxn(() async {
          await _isarInstance!.playlist_Songs.deleteAll(songIds);
        });
      }
      debugPrint("Cleaned playlist");
    } catch (e) {
      debugPrint("Failed to clean playlist: $e");
    }
  }


  // 根据路径搜索歌曲索引
  static Future<int> searchSongIndex(String path) async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }
    final songs = await _isarInstance!.songs.where().findAll();
    for (var i = 0; i < songs.length; i++) {
      if (songs[i].path == path) {
        return i;
      }
    }
    return -1;
  }

  // 根据路径删除歌曲
  static Future<void> deleteSong(String path) async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }
    final songs =
        await _isarInstance!.songs.filter().pathEqualTo(path).findAll();
    if (songs.isNotEmpty) {
      final song = songs.first;
      if (song.id == null) {
        throw Exception("Song ID is null");
      }
      await _isarInstance!.writeTxn(() async {
        await _isarInstance!.songs.delete(song.id!);
      });
      // 删除歌曲时，同时删除播放列表中的记录(未完成)

    }
  }

  // 创建播放列表
  static Future<void> createPlaylist() async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }
    final playlist = Playlist()
      ..id = 0
      ..name = '播放列表';
    await _isarInstance!.writeTxn(() async {
      await _isarInstance!.playlists.put(playlist);
    });
  }

  // 将播放列表中的歌曲添加到数据库
  static Future<void> addSongsToPlay(String name) async {
    if (_isarInstance == null) {
      throw Exception("Isar instance not initialized");
    }

    // 检查是否存在同名记录
    final existingSong = await _isarInstance!.playlist_Songs
        .filter()
        .nameEqualTo(name)
        .findFirst();

    // 如果存在同名记录，先删除该记录
    if (existingSong != null) {
      await _isarInstance!.writeTxn(() async {
        await _isarInstance!.playlist_Songs.delete(existingSong.id!);
      });
    }

    // 获取歌曲信息
    final s = await _isarInstance!.songs.filter().nameEqualTo(name).findFirst();

    // 创建新的 Playlist_Song 对象
    final p = Playlist_Song()
      ..name = name
      ..path = s!.path;

    // 添加新的记录
    await _isarInstance!.writeTxn(() async {
      await _isarInstance!.playlist_Songs.put(p);
    });
  }
}
