import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bird_music/Data/database_helper.dart';
import 'package:bird_music/Data/playtag.dart';
import 'package:path/path.dart' as path;
import 'package:isar/isar.dart';
import 'package:bird_music/Data/song_playlist.dart';

class ScanMusicFolder extends ChangeNotifier {
  static scanMusicFolder(Isar isar, List<String> folderPath) async {
    int newSongCount = 0; // 记录新增歌曲的数量
    for (var folder in folderPath) {
      // 获取文件夹中的所有文件
      List<FileSystemEntity> files = Directory(folder).listSync();
      for (var file in files) {
        if (file is File && isMusicFile(file.path)) {
          // 提取音乐文件信息
          String filePath = file.path.replaceAll(r'\', '/');
          String fileName = path.basenameWithoutExtension(file.path);
          // 检查数据库中是否已经存在相同路径的歌曲
          final existingSong =
              await isar.songs.filter().pathEqualTo(filePath).findFirst();
          if (existingSong == null) {
            DatabaseHelper.addSong(filePath); // 向数据库添加歌曲
            Map<String, dynamic> tags = {'title': fileName.split(' - ').first, 'trackArtist': fileName.split(' - ')};
            filePath = filePath.replaceAll(r'\', '/');
            PlayTag.writeTag(filePath, tags); // 写入歌曲标签信息
            newSongCount++; // 新增歌曲数量加1
          }
        }
      }
    }
    debugPrint("扫描完成，新增了 $newSongCount 首歌曲");
  }

  static isMusicFile(String filePath) {
    // 判断文件是否为音乐文件
    final musicExtensions = ['.mp3', '.wav', '.flac', '.aac'];
    return musicExtensions.contains(path.extension(filePath).toLowerCase());
  }
}
