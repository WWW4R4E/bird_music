import 'dart:io';
import 'dart:typed_data';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/widgets.dart';
import 'package:id3_codec/id3_codec.dart';
import 'package:bird_music/Data/http_download.dart';
import 'package:bird_music/Data/music_service.dart';

class PlayTag {
  static Future<Map<String, dynamic>> getTag(String path) async {
    try {
      final tag = await AudioTags.read(path);
      if (tag == null) {
        return {}; // 或者根据需要返回其他默认值
      }
      // 手动构建Map，处理可能的 null 值
      return {
        'title': tag.title ?? '', //歌曲名
        'trackArtist': tag.trackArtist ?? '', //歌手名
        // 'album': tag.album ?? '', //专辑名
        // 'albumArtist': tag.albumArtist ?? '', //专辑歌手名
        'genre': tag.genre ?? '', //流派
        'year': tag.year ?? 0, //年份
        // 'trackNumber': tag.trackNumber ?? 0, //歌曲序号
        // 'trackTotal': tag.trackTotal ?? 0, //总共歌曲数
        // 'discNumber': tag.discNumber ?? 0, //碟片序号
        // 'discTotal': tag.discTotal ?? 0, //总共碟片数
        'duration': tag.duration ?? 0, //时长
        'pictures': tag.pictures,
      };
    } catch (e) {
      // 处理异常，例如记录日志或返回默认值
      debugPrint("Error reading tag: $path");
      return {}; // 或者根据需要返回其他默认值
    }
  }

  // 写入元数据(注意写入文件的前提是这玩意有ID3v2标签)
  static Future<bool> writeTag(String path, Map<String, dynamic> tags) async {
    try {
      // 读取当前文件的元数据
      var existingTags = await getTag(path);
      if (existingTags['pictures'] != null &&
          existingTags['pictures'].isNotEmpty) {
        debugPrint("File already contains picture metadata: $path");
        return true; // 如果已经有图片元数据，则跳过写入
      }

      // 等待异步获取图片字节数据
      debugPrint('title: ${tags['title']} , trackArtist: ${tags['trackArtist']}');
      var songInfo =
          await MusicService().getSongInfo(tags['title'], tags['trackArtist']);
      if (songInfo.$1 == null) {
        debugPrint("Can't find song info: $path");
        return false;
      }
      debugPrint("lyric: /n${songInfo.$2}");
      String firstString = songInfo.$1!;
      debugPrint("firstString: $firstString");
      var result = await ssjRequestManager.getBytes(firstString, {});
      Uint8List imageBytes = result;

      // 压缩图片
      // headerBytes = await ImageCompressor.compressImage(
      //   imageBytes,
      //   quality: 50,
      //   targetWidth: 128,
      //   targetHeight: 128,
      // );

      // 读取音乐文件
      final bytes = await File(path).readAsBytes();

      // 创建ID3编码器
      final encoder = ID3Encoder(bytes);

      // 编码ID3v2.3标签（ID3v2.4就把MetadataV2p3Body改成MetadataV2p4Body）
      final resultBytes = encoder.encodeSync(MetadataV2p3Body(
        imageBytes: imageBytes,
        
      ));

      // 写入文件
      var file = File('c:/Users/123/Downloads/456.mp3');

      // 写入文件
      await file.writeAsBytes(resultBytes);
      debugPrint("Write tag success: $path");
      return true;
    } catch (e) {
      debugPrint('$e');
      debugPrint("Error writing tag: $path");
      return false;
    }
  }
}
