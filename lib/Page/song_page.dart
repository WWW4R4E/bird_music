import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bird_music/Bar/music_bar.dart';
import 'package:bird_music/Data/database_helper.dart';
import 'package:bird_music/Song/words_music.dart';
import 'package:provider/provider.dart';
import 'package:bird_music/Bar/title_bar.dart';
import 'package:bird_music/Data/music_player_provider.dart';

class SongPage extends StatefulWidget {
  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  String lyrics = '';
  MusicPlayerProvider musicPlayer = MusicPlayerProvider();

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    final songName = Provider.of<MusicPlayerProvider>(context, listen: false).songName ?? "";
    lyrics = await DatabaseHelper.getLyrics(songName);
    setState(() {}); // 更新 UI
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕大小
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // 获取图片
    Uint8List? picture = Provider.of<MusicPlayerProvider>(context).picture;

    return Scaffold(
      body: Stack(
        children: [
          if (picture != null)
            Image.memory(
              picture,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            Image.asset(
              'assets/image/birde.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          // 高斯模糊背景
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: TitleBar(songpage: true),
              ),
              Row(
                children: [
                  SizedBox(
                    height: screenHeight * 0.8,
                    width: screenWidth * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            musicPlayer.songName ?? "  ",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: screenHeight * 0.4,
                            height: screenHeight * 0.4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: picture != null
                                    ? MemoryImage(picture)
                                    : const AssetImage("assets/image/测试歌曲图片.jpg"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // 歌词
                      Container(
                        height: screenHeight * 0.8,
                        width: screenWidth * 0.4,
                        // 定义一个装饰器，用于设置盒子的边框半径和阴影效果
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10), // 设置盒子的边框半径为10
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1), // 设置阴影颜色为黑色，透明度为0.1
                              blurRadius: 10, // 设置阴影的模糊半径为10
                            ),
                          ],
                        ),
                        child: lyrics.isNotEmpty
                            ? WordsMusic(lyrics: lyrics)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // MusicBar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MusicBar(
              progressBarWidth: screenWidth * 0.5,
              musicBarHeight: 80,
              page: 'song_page',
            ),
          ),
        ],
      ),
    );
  }
}
