import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:bird_music/Data/music_player_provider.dart';
import 'package:bird_music/Bar/songlist_bar.dart';
import 'package:bird_music/Data/class.dart';

class MusicBar extends StatefulWidget {
  final double progressBarWidth;
  final double musicBarHeight;
  final String? playingMusic;
  final int? currentIndex;
  final Uint8List? picture;
  final String? page;

  const MusicBar({
    required this.progressBarWidth,
    required this.musicBarHeight,
    this.page,
    this.playingMusic,
    this.currentIndex,
    this.picture,
  });

  @override
  MusicBarState createState() => MusicBarState();
}

class MusicBarState extends State<MusicBar> {
  @override
  void initState() {
    if (widget.page == null) {
      super.initState();
      Provider.of<MusicPlayerProvider>(context, listen: false)
          .updatePlayerSource(widget.playingMusic);
    }
  }

  @override
  void didUpdateWidget(covariant MusicBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playingMusic != oldWidget.playingMusic) {
      Provider.of<MusicPlayerProvider>(context, listen: false)
          .updatePlayerSource(widget.playingMusic);
      debugPrint("MusicBar didUpdateWidget");
    }
  }

  // 右侧弹窗
  void _showRightSlideDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.grey.withOpacity(0.5),
            child: Consumer<PlaylistArray>(
              builder: (context, playlistArray, child) {
                return SongList(
                  songArray: playlistArray.playlistSongs.toList(),
                  playlist: "playlist",
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  //音量条
  void _showVolumeDialog(BuildContext context) {
    final RenderBox buttonRenderBox = context.findRenderObject() as RenderBox;
    final buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);
    double left = buttonPosition.dx;
    double top = buttonPosition.dy + buttonRenderBox.size.height / 2;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: left + 10,
              top: top - 170,
              child: Material(
                color: Colors.grey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Consumer<MusicPlayerProvider>(
                          builder: (context, musicPlayer, child) {
                            return SizedBox(
                              height: 150, // 调整高度以适应竖直方向
                              child: RotatedBox(
                                quarterTurns: 3, // 旋转270度（3 * 90度）
                                child: SliderTheme(
                                  data: const SliderThemeData(
                                      // valueIndicatorStrokeColor: Colors.green,
                                      activeTrackColor:
                                          Colors.blue, // 设置活动轨道的颜色
                                      thumbColor: Colors.white, // 设置滑块的颜色
                                      overlayColor: Colors.white, // 设置滑块的覆盖颜色
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 10),
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 5,
                                        disabledThumbRadius: 5,
                                      )),
                                  child: Slider(
                                    value: musicPlayer.volume.toDouble(),
                                    min: 0,
                                    max: 100,
                                    label: musicPlayer.volume.toString(),
                                    onChanged: (value) {
                                      try {
                                        musicPlayer.setVolume((value).toInt());
                                      } catch (e) {
                                        debugPrint("Error setting volume: $e");
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final picture = Provider.of<MusicPlayerProvider>(context).picture;
    return Consumer<MusicPlayerProvider>(
      builder: (context, musicPlayer, child) {
        return Container(
          height: widget.musicBarHeight,
          color: Colors.black.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 歌曲图片
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.page != 'song_page'
                    ? GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/song');
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: picture != null
                                  ? MemoryImage(picture)
                                  : const AssetImage("assets/image/测试歌曲图片.jpg"),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // 进度条
                  SizedBox(
                    width: widget.progressBarWidth,
                    height: 20,
                    child: ProgressBar(
                      // 定义音乐播放器进度条的样式和行为
                      progress: musicPlayer.position, // progress: 当前音乐播放器的位置
                      buffered: musicPlayer.buffered, // buffered: 已缓冲的音乐部分
                      total: musicPlayer.duration, // total: 音乐的总时长
                      onSeek:
                          musicPlayer.seek, // onSeek: 当用户拖动进度条时，调用音乐播放器的seek方法
                      baseBarColor: Colors.white24, // baseBarColor: 进度条底部的颜色
                      progressBarColor:
                          Colors.grey, // progressBarColor: 进度条已播放部分的颜色
                      thumbColor: Colors.transparent, // thumbColor: 进度条滑块的颜色
                      thumbGlowRadius: 0, // thumbGlowRadius: 滑块发光效果的半径
                      thumbRadius: 5, // thumbRadius: 滑块的半径
                    ),
                  ),
                  Row(
                    children: [
                      // 上一首
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: musicPlayer.playPrevious,
                      ),
                      // 播放/暂停按钮
                      IconButton(
                        icon: Icon(
                          musicPlayer.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: musicPlayer.playPause,
                      ),
                      // 下一首
                      IconButton(
                        icon: const Icon(Icons.skip_next,
                            size: 30, color: Colors.white),
                        onPressed: musicPlayer.playNext,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // 音量控制
              Builder(
                builder: (BuildContext icontext) {
                  return IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.white),
                    onPressed: () {
                      _showVolumeDialog(icontext);
                    },
                  );
                },
              ),
              const SizedBox(width: 20),

              // 播放列表
              IconButton(
                icon: const Icon(Icons.list, color: Colors.white),
                onPressed: _showRightSlideDialog,
              ),
            ],
          ),
        );
      },
    );
  }
}
