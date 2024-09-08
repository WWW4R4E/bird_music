import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bird_music/Data/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:bird_music/Data/class.dart';
import 'package:bird_music/Data/music_player_provider.dart';
import 'package:bird_music/Data/playtag.dart';

class SongList extends StatefulWidget {
  // 歌曲列表组件，接受一个歌曲数组和一个可选的播放列表名称
  final List<Song> songArray;
  final String? playlist;
  const SongList({super.key, required this.songArray, this.playlist});

  @override
  SongListState createState() => SongListState();
}

class SongListState extends State<SongList> {
  // 歌单图片路径列表
  List<String> picturePathList = [];
  // 当前选中的歌曲索引
  int? _selectedIndex;
  // 获取歌名列表
  List<String> getSongNames() {
    return widget.songArray.map((song) => song.name).toList();
  }

  // 图片和作者信息缓存，用于存储歌曲封面图片和作者信息
  Map<int, Map<String, dynamic>> infoCache = {};

  @override
  void initState() {
    super.initState();
    // 调用异步方法加载图片路径列表
    _loadPicturePathList();
  }

  Future<void> _loadPicturePathList() async {
    // 读取文件夹信息
    final dynamicFolders = await readFolder('封面位置');
    setState(() {
      // 使用 setState 更新 picturePath
      picturePathList = dynamicFolders.cast<String>();
    });
  }

  // 重新初始化组件主体
  void reinitializeBody() {
    setState(() {});
  }

  

  @override
  Widget build(BuildContext context) {
    final musicPlayerProvider =
        Provider.of<MusicPlayerProvider>(context, listen: true);
    // 更新当前选中的歌曲索引（播放列表和歌单都可以因为这个正确选中歌曲）
    _selectedIndex = getSongNames().indexOf(musicPlayerProvider.songName ?? "");
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        toolbarHeight: widget.playlist == null ? 250 : 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: widget.playlist == null
            ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 40),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: picturePathList.isNotEmpty
                            ? Image.file(
                                File(picturePathList[0]),
                                width: 200,
                                height: 200,
                              ) //歌单封面
                            : Container(
                                color: Colors.grey,
                                height: 200,
                                width: 200,
                              ),
                      ),
                      const SizedBox(width: 50),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 140,
                            child: Column(
                              children: [
                                Text(
                                  '你的歌单',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '简介',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BottomAppBar(
                            color: Colors.transparent,
                            shape: const CircularNotchedRectangle(),
                            notchMargin: 4.0,
                            child: Row(
                              children: [
                                // 分隔距离
                                IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  color: Colors.white,
                                  onPressed: () {
                                    debugPrint("播放歌单");
                                  },
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.menu),
                                  color: Colors.white,
                                  onPressed: () {
                                    debugPrint("全选歌单");
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Divider(height: 3, color: Colors.grey[500]),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // 确保文字在左边，按钮在右边
                children: [
                  const Text(
                    "播放列表",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        _selectedIndex = null;
                      });
                      // 清理播放列表
                      Provider.of<PlaylistArray>(context, listen: false)
                          .deletePlaylist();
                      // 清理数据库
                      print("清理播放列表");
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: widget.songArray.length,
        cacheExtent: widget.songArray.length.toDouble(), // 增加预渲染区域
        itemBuilder: (BuildContext context, int index) {
          return RepaintBoundary(
            child: Column(
              children: [
                _buildSongItem(widget.songArray[index].name, index),
                if (index < widget.songArray.length - 1) // 手动添加分隔符
                  const Divider(
                    thickness: 4,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建单个歌曲项
  Widget _buildSongItem(
    String songName,
    int index,
  ) {
    final double musicSize = MediaQuery.of(context).size.height / 16;
    // 读取歌曲元数据
    Map<String, dynamic>? info = infoCache[index];
    Uint8List? picture = info?['picture'];
    String? title = info?['title'];
    String? trackArtist =
        ((info != null) && (info['trackArtist'] ?? '').isNotEmpty)
            ? info['trackArtist']
            : '未知歌手';
    if (info == null) {
      // 异步获取图片数据和作者信息并缓存
      PlayTag.getTag(widget.songArray[index].path).then((tags) {
        String title = tags['title'];
        if (title.isEmpty) {
          title = songName;
        }
        infoCache[index] = {
          'picture': tags['pictures'] != null && tags['pictures'].isNotEmpty
              ? tags['pictures'].first.bytes
              : null,
          "title": title,
          'trackArtist': tags['trackArtist'],
        };
        // print('歌名：$title, 歌手：$trackArtist');

        // 使用局部刷新，避免整个列表刷新
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }).catchError((error) {
        // 打印错误信息
        debugPrint("Error fetching tag: $error");
      });
    }

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(_selectedIndex == index ? 100 : 50),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              enableFeedback: true,
              borderRadius: BorderRadius.circular(8.0),
              splashColor: Colors.transparent,
              onTap: () {
                // 更新当前播放歌曲
                Provider.of<MusicPlayerProvider>(context, listen: false)
                    .updatePlayerSource(widget.songArray[index].path,);
                Provider.of<MusicPlayerProvider>(context, listen: false)
                    .updatePicture(picture);
                // 将当前歌曲添加到播放列表
                Provider.of<PlaylistArray>(context, listen: false)
                    .addPlaylist(songName);
                // 将当前歌曲添加到数据库
                DatabaseHelper.addSongsToPlay(songName);
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: picture != null
                        ? Image.memory(
                            picture,
                            height: musicSize,
                            width: musicSize,
                          )
                        : SizedBox(
                            width: musicSize,
                            height: musicSize,
                            child: const Image(
                              image: AssetImage("assets/image/测试歌曲图片.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? songName,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 1, // 只显示一行
                          overflow: TextOverflow.ellipsis, // 超过部分用省略号表示
                        ),
                        Text(
                          trackArtist ?? '加载中...', // 显示作者信息
                          style: const TextStyle(fontSize: 12), // 小字
                          maxLines: 1, // 只显示一行
                          overflow: TextOverflow.ellipsis, // 超过部分用省略号表示
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
