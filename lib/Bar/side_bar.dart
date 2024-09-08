import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bird_music/Data/database_helper.dart';
import 'package:bird_music/Data/class.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  SideBarState createState() => SideBarState();
}

class SideBarState extends State<SideBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _simulateTapOnHome();
    });
  }

  void _simulateTapOnHome() async {
    List<Song> songs = (await DatabaseHelper.getLocalSongs())
        .map((map) => Song.fromMap(map))
        .toList();

  // debugPrint('songs:');
  // for (var song in songs) {
  //   debugPrint('Title: ${song.name}, imageurl: ${song.imageurl}, lyric: ${song.lyrics}'); //测试song数据是否正确
  // }
    if (mounted) {
      // 检查 BuildContext 是否仍然有效
      Provider.of<SongArray>(context, listen: false).updateSongs(songs);
    }
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(50),
      height: double.infinity,
      width: 250,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar(
              title: Text("Music App",
                  style: TextStyle(color: Colors.white, fontSize: 28)),
              centerTitle: true,
              pinned: true, // 标题栏固定在顶部
              expandedHeight: 70.0, // 展开高度
              backgroundColor: Colors.transparent,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 10,
                    child: Divider(height: 3, color: Colors.grey[500]),
                  ),
                  _buildSideBarItem(Icons.home, "全部音乐", 0),
                  _buildSideBarItem(Icons.settings, "设置", 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBarItem(IconData icon, String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(_selectedIndex == index ? 100 : 0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            enableFeedback: true,
            hoverColor: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.transparent,
            onTap: () async {
              onItemTapped(index);
              Provider.of<SideBarIndex>(context, listen: false)
                  .updateIndex(index);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color:
                          _selectedIndex == index ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      label,
                      style: TextStyle(
                        color: _selectedIndex == index
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
