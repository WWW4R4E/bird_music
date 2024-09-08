import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bird_music/Data/data_refresh.dart';
import 'package:bird_music/Data/scan_music_folder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import 'package:bird_music/Data/class.dart';
import 'package:bird_music/Data/database_helper.dart';
import 'package:bird_music/Data/music_player_provider.dart';
import 'package:bird_music/Page/home_page.dart';
import 'package:bird_music/Page/song_page.dart';


void main() async {
  //检测是否有json数据，如果没有则创建
  final directory = await getApplicationSupportDirectory();
  final jsonPath = p.join(directory.path, 'folders.json');
  if (!await File(jsonPath).exists()) {
    // 创建一个空的json文件
    await File(jsonPath).writeAsString('{"文件管理":[],"背景管理":[]," 歌单封面":[]}'); 
  }
  // 初始化数据库
  final isar = await DatabaseHelper.initializeIsar();
  // 音乐文件夹路径
  final dynamicFolders = await readFolder("文件管理");
  // 将 List<dynamic> 转换为 List<String>
  final List<String> folders = dynamicFolders.cast<String>();
  // 扫描音乐文件夹
  await ScanMusicFolder.scanMusicFolder(isar, folders);
  // 监听音乐文件夹
  if (folders.isNotEmpty) {
    dataRefresh(folders);
  }
  // 创建播放列表
  DatabaseHelper.createPlaylist(); 
  // 确保初始化
  WidgetsFlutterBinding.ensureInitialized(); 
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    size: Size(1200, 800),
    alwaysOnTop: false,
    // 隐藏标题栏
    titleBarStyle: TitleBarStyle.hidden, 
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    windowManager.setHasShadow(true);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SongArray()),
        ChangeNotifierProvider(create: (context) => MusicPlayerProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistArray()),
        ChangeNotifierProvider(create: (context) => SideBarIndex()),
        ChangeNotifierProvider(create: (context) => PicturePathProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Birde Music',
        themeMode: ThemeMode.system,
        onGenerateRoute: (settings) {
          if (settings.name == '/song') {
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SongPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = const Offset(0, 1);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          }
          return null;
        },
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => const HomePage(),
        },
      ),
    ),
  );
}
