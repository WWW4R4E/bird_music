import 'dart:io';
import 'package:flutter/widgets.dart';

import 'database_helper.dart';

Future<void> dataRefresh(List<String> directoryPaths) async {
  for (var directoryPath in directoryPaths) {
    // 创建一个 Directory 对象
    final directory = Directory(directoryPath);

    // 创建一个监听器
    final watcher = directory.watch(recursive: true);

    // 监听文件变化事件
    watcher.listen((FileSystemEvent event) {
      switch (event.type) {
        case FileSystemEvent.create:
          debugPrint('文件创建: ${event.path.replaceAll(r'\', '/')}');
          DatabaseHelper.addSong(event.path.replaceAll(r'\', '/'));
          break;
        case FileSystemEvent.modify:
          debugPrint('文件修改: ${event.path.replaceAll(r'\', '/')}');
          break;
        case FileSystemEvent.delete:
          debugPrint('文件删除: ${event.path.replaceAll(r'\', '/')}');
          DatabaseHelper.deleteSong(event.path.replaceAll(r'\', '/'));
          break;
        case FileSystemEvent.move:
          debugPrint('文件移动: ${event.path.replaceAll(r'\', '/')}');
          DatabaseHelper.deleteSong(event.path.replaceAll(r'\', '/'));
          break;
      }
    });

    debugPrint('正在监听文件夹: $directoryPath');
  }
}
