import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:bird_music/Data/music_player_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bird_music/Data/database_helper.dart';
import 'package:provider/provider.dart';

class Playlist {
  final Id? id;
  final String name;
  final String? description;

  Playlist({this.id, required this.name, this.description});
}

class Song {
  final String path;
  final String name;
  // String imageurl ;
  final String lyrics;

  Song(
      {required this.path,
      required this.name,
      required this.lyrics //  required this.imageurl,
      });

  @override
  int get hashCode => name.hashCode ^ path.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Song && other.name == name && other.path == path;
  }

  static Song fromMap(Map<String, dynamic> map) {
    return Song(
        name: map['name'],
        path: map['path'],
        lyrics: map['lyrics'] //  imageurl: map['imageUrl'],
        );
  }
}

class SongArray extends ChangeNotifier {
  List<Song> _songs = [];

  List<Song> get songs => _songs;

  void updateSongs(List<Song> newSongs) {
    _songs = newSongs;
    notifyListeners();
  }
}

class PlaylistArray extends ChangeNotifier {
  Set<Song> _playlistSongs = {};
  PlaylistArray() {
    init();
  }
  Set<Song> get playlistSongs => _playlistSongs;

  Future<void> init() async {
    try {
      // 将整页歌单加入播放列表
      List<Map<String, dynamic>> songs = await DatabaseHelper.getSongs();
      _playlistSongs = songs.map((song) => Song.fromMap(song)).toSet();
      Provider.of<MusicPlayerProvider>(context as BuildContext, listen: false)
          .updatePlayerSource(null);
      debugPrint("初始化播放列表成功: $_playlistSongs");
      // notifyListeners();
    } catch (e) {
      debugPrint("初始化播放列表失败: $e");
    }
  }

  Future<void> addPlaylist(String name) async {
    try {
      Map<String, dynamic> songMap = await DatabaseHelper.searchSong(name);
      Song song = Song.fromMap(songMap);
      if (!_playlistSongs.contains(song)) {
        _playlistSongs.add(song);
        // debugPrint("添加歌曲到播放列表: ${song.name}");
        // debugPrint("播放列表: ${_playlistSongs.map((song) => song.name).toList()}");
        notifyListeners();
      } else {
        // debugPrint("歌曲已存在于播放列表中: ${song.name}");
      }
    } catch (e) {
      debugPrint("添加歌曲失败: $e");
    }
  }

  Future<void> deletePlaylist() async {
    try {
      await DatabaseHelper.cleanPlaylist();
      await init(); // 重新初始化播放列表
      notifyListeners(); // 通知 UI 更新
    } catch (e) {
      debugPrint("删除播放列表失败: $e");
    }
  }
}

class SideBarIndex extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void updateIndex(int newIndex) {
    _index = newIndex;
    notifyListeners();
  }
}

class PicturePathProvider with ChangeNotifier {
  String _picturePath = '';
  String get picturePath => _picturePath;

  void updatePicturePath() async {
    List<dynamic> folderContents = await readFolder('背景管理');
    if (folderContents.isNotEmpty) {
      _picturePath = folderContents[0];
      debugPrint("图片路径更新: $_picturePath");
      notifyListeners();
    } else {
      debugPrint("文件夹为空");
    }
  }
}

Future<List<dynamic>> readFolder(String folderPath) async {
  final directory = await getApplicationSupportDirectory();
  final filePath = '${directory.path}/folders.json';
  final file = File(filePath);
  final folderJson = await file.readAsString();
  final Map<String, dynamic> playlistMaps = json.decode(folderJson);
  final List<dynamic> dynamicFolders = playlistMaps[folderPath] ?? [];
  return dynamicFolders;
}
