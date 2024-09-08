import 'package:isar/isar.dart';

part 'song_playlist.g.dart';

//代码生成器生成的代码 
//flutter pub run build_runner build

@Collection()
class Playlist {
  Id? id;
  late String name;
}

@Collection()
class Song {
  Id? id;
  late String name;
  late String path;
  late String lyric;
  final playlist = IsarLinks<Playlist>();
}

@Collection()
class Playlist_Song {
  Id? id;
  late String name;
  late String path;
}

