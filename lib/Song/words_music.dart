import 'package:flutter/material.dart';
import 'package:bird_music/Data/music_player_provider.dart';
import 'package:provider/provider.dart';

// 显示歌词的页面
class WordsMusic extends StatefulWidget {
  final String lyrics;
  WordsMusic({super.key, required this.lyrics});

  @override
  _WordsMusicState createState() => _WordsMusicState();
}

// WordsMusic 页面的状态类
class _WordsMusicState extends State<WordsMusic> {
  List<LyricLine> lyricLines = [];
  ScrollController _scrollController = ScrollController();
  int currentLineIndex = 0;
  bool _isControllerAttached = false;
  double itemHeight = 50.0; // 初始假设值

  @override
  void initState() {
    super.initState();
    parseLyrics(widget.lyrics);
    _scrollController.addListener(() {
      if (_scrollController.positions.isNotEmpty) {
        setState(() {
          _isControllerAttached = true;
        });
      }
    });
  }

  // 解析歌词字符串
  void parseLyrics(String lyrics) {
    List<String> lines = lyrics.split('\n');
    for (var line in lines) {
      if (line.isNotEmpty) {
        var parts = line.split(']');
        if (parts.length > 1) {
          var timePart = parts[0].substring(1); // 去掉开头的 '['
          var text = parts[1];
          var time = parseTime(timePart);
          lyricLines.add(LyricLine(time: time, text: text));
        }
      }
    }
  }

  // 解析时间字符串为 Duration 对象
  Duration parseTime(String timePart) {
    var parts = timePart.split(':');
    var minutes = int.parse(parts[0]);
    var seconds = double.parse(parts[1]);
    return Duration(minutes: minutes, seconds: seconds.toInt(), milliseconds: ((seconds % 1) * 1000).toInt());
  }

  // 同步歌词与当前播放时间
  void syncLyrics(Duration currentTime) {
    if (!_isControllerAttached) return;

    for (var i = 0; i < lyricLines.length; i++) {
      if (currentTime >= lyricLines[i].time && (i == lyricLines.length - 1 || currentTime < lyricLines[i + 1].time)) {
        if (currentLineIndex != i) {
          setState(() {
            currentLineIndex = i;
          });
          _scrollToCenter(i);
        }
        break;
      }
    }
  }

  // 滚动到指定行并使其居中
  void _scrollToCenter(int index) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double centerOffset = (screenHeight / 2) - (itemHeight / 2); // 计算居中偏移量
    final double targetOffset = (index+1) * itemHeight - centerOffset;  // 计算目标偏移量

    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // 处理歌词点击事件
  void onLyricTap(int index) {
    final musicPlayerProvider = Provider.of<MusicPlayerProvider>(context, listen: false);
    musicPlayerProvider.seek(lyricLines[index].time);
    setState(() {
      currentLineIndex = index;
    });
    _scrollToCenter(index);
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前播放时间
    final currentTime = Provider.of<MusicPlayerProvider>(context).position;

    syncLyrics(currentTime);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: lyricLines.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onLyricTap(index),
                child: SongLyrics(
                  text: lyricLines[index].text,
                  isCurrent: index == currentLineIndex,
                  onLayout: (double height) {
                    setState(() {
                      itemHeight = height;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 表示单行歌词的类
class LyricLine {
  final Duration time;
  final String text;

  LyricLine({required this.time, required this.text});
}

// 显示单行歌词的 Widget
class SongLyrics extends StatefulWidget {
  final String text;
  final bool isCurrent;
  final Function(double) onLayout;

  const SongLyrics({super.key, required this.text, this.isCurrent = false, required this.onLayout});

  @override
  SongLyricsState createState() => SongLyricsState();
}
class SongLyricsState extends State<SongLyrics> {
  // 构建方法，返回一个带有文本的Padding组件
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        widget.text.isNotEmpty ? widget.text : ' ', // 处理空文本
        style: TextStyle(
          fontSize: 28,
          color: widget.isCurrent ? Colors.red : Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 当依赖关系发生变化时调用，获取渲染对象的高度并调用回调函数
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      widget.onLayout(renderBox.size.height);
    });
  }
}
