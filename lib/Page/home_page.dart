import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bird_music/Bar/setting_bar.dart';
import 'package:provider/provider.dart';
import 'package:bird_music/Data/class.dart';
import 'package:bird_music/Bar/music_bar.dart';
import 'package:bird_music/Bar/title_bar.dart';
import 'package:bird_music/Bar/songlist_bar.dart';
import 'package:bird_music/Bar/side_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String picturePath = '';

  @override
  void initState() {
    super.initState();
    readPicturePath("背景管理").then((path) {
      if (picturePath != path) {
        picturePath = path;
        setState(() {});
      }
    });
  }

  Future<String> readPicturePath(String folderName) async {
    final dynamicFolders = await readFolder(folderName);
    final path = dynamicFolders.cast<String>().first;
    return path;
  }

  @override
  Widget build(BuildContext context) {
    const double appBarHeight = 80;
    const double musicBarHeight = 80;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int index = Provider.of<SideBarIndex>(context).index;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 背景图片
            Consumer<PicturePathProvider>(
              builder: (context, picturePathProvider, child) {
                if (picturePathProvider.picturePath != '' &&
                    picturePath != picturePathProvider.picturePath) {
                  picturePath = picturePathProvider.picturePath;
                  debugPrint('更新图片路径：$picturePath');
                }
                return picturePath.isNotEmpty // 检查 picturePath 是否为空
                    ? Image.file(
                        File(picturePath),
                        color: Colors.black.withOpacity(0.5),
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.asset(
                        'assets/image/birde.png',
                        color: Colors.black.withOpacity(0.5),
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
              },
            ),
            // 高斯模糊背景
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            // 右侧页面
            Positioned.fill(
              top: appBarHeight, // 调整顶部位置，避免被AppBar遮挡
              bottom: musicBarHeight, // 调整底部位置，避免被MusicBar遮挡
              left: 250,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300), // 设置动画时长
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: index == 0
                    ? Consumer<SongArray>(
                        key: const ValueKey(0), // 确保AnimatedSwitcher识别到子组件的变化
                        builder: (context, songArray, _) {
                          return SongList(
                            songArray: songArray.songs,
                          );
                        },
                      )
                    : const SettingsPage(
                        key: ValueKey(1)), // 确保AnimatedSwitcher识别到子组件的变化,
              ),
            ),
            //侧边栏
            const Positioned(
              top: 0,
              left: 0,
              bottom: musicBarHeight,
              width: 250,
              child: SideBar(),
            ),
            // TitleBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                toolbarHeight: appBarHeight,
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0, // 取消阴影
                backgroundColor: Colors.transparent,
                title: const TitleBar(),
                elevation: 0,
              ),
            ),
            // MusicBar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MusicBar(
                progressBarWidth: screenWidth * 0.5,
                musicBarHeight: musicBarHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
