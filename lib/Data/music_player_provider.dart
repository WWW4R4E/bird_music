import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bird_music/Data/database_helper.dart';

class MusicPlayerProvider with ChangeNotifier {
  bool _isPlaying = false;
  String? _songName;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  final Duration _buffered = Duration.zero;
  String? _currentSong;
  Uint8List? _picture;
  List<String> _playlist = []; // 播放列表
  int _volume = 100; // 音量
  int? _currentIndex = 0; // 当前歌曲在播放列表中的索引
  String? get songName => _songName;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  Duration get buffered => _buffered;
  int get volume => _volume;
  Uint8List? get picture => _picture;
  String? get currentSong => songName;
  int? get currentIndex => _currentIndex;

  // 构造函数，初始化音乐播放器提供者
  MusicPlayerProvider() {
    // 监听播放器时长变化，更新_duration并通知监听者
    _player.onDurationChanged.listen((Duration d) {
      _duration = d;
      notifyListeners();
    });
    // 监听播放器位置变化，更新_position并通知监听者
    _player.onPositionChanged.listen((Duration p) {
      _position = p;
      notifyListeners();
    });
    // 监听播放器状态变化，根据状态执行相应操作并通知监听者
    _player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        playNext();
      }
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    // 初始化播放列表
    _initPlaylist();
  }

  // 初始化播放列表，从本地数据库获取歌曲并将其路径转换为列表
  Future<List<String>> _initPlaylist() async {
    final songs = await DatabaseHelper.getSongs();
    _playlist = songs.map((song) => song['path'] as String).toList();
    // print( '播放列表：$_playlist');
    return _playlist;
  }


  // 播放或暂停当前歌曲
  Future<void> playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_currentSong == null) {
        debugPrint('当前没有歌曲播放');
      } else {
        await _player.resume();
      }
    }
    notifyListeners();
  }

  // 跳转到指定的时间点
  Future<void> seek(Duration duration) async {
    await _player.seek(duration);
  }

  // 更新播放器源，设置新的音乐路径和当前索引
  Future<void> updatePlayerSource(String? musicPath) async {
    if (musicPath == null) {
      await _player.pause();
    } else {
      musicPath = musicPath.replaceAll(r'\', r'/');
      debugPrint(musicPath);
      _songName = musicPath.split('/').last.split('.').first;
      _currentSong = musicPath;
      await _player.play(DeviceFileSource(musicPath.replaceAll(r'\', r'/')));
      _currentIndex = _playlist.indexOf(musicPath);
    }
    _isPlaying = musicPath != null;
    notifyListeners();
  }

  // 播放上一首歌曲
  void playPrevious() {
    print('currentIndex:$currentIndex');
    if (currentIndex! > 0) {
      updatePlayerSource(_playlist[currentIndex! - 1]);
    } else {
      // 如果已经是第一首，可以循环播放或者停止
      updatePlayerSource(
        _playlist.last,
      );
    }
    debugPrint('$currentIndex');
    notifyListeners(); // 通知所有监听者，数据发生了改变
  }

  // 播放下一首歌曲
  void playNext() {
    print(currentIndex);
    if (currentIndex! < _playlist.length - 1) {
      updatePlayerSource(_playlist[currentIndex! + 1]);
    } else {
      // 如果已经是最后一首，可以循环播放或者停止
      updatePlayerSource(
        _playlist.first,
      );
    }
    debugPrint('$currentIndex');
    notifyListeners(); // 通知所有监听者，数据发生了改变
  }

  // 音量调节
  Future<void> setVolume(int volume) async {
    _volume = volume;
    await _player.setVolume(volume / 100.0);
    // debugPrint('音量：${volume}');
    notifyListeners(); // 通知所有监听者，数据发生了改变
  }

  // 更新当前歌曲的封面图片
  void updatePicture(Uint8List? picture) {
    if (picture == null) {
      _picture = null;
    }
    _picture = picture;
    notifyListeners();
  }

  // 释放播放器资源
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
