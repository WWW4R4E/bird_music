import 'dart:convert';
import 'dart:io';
import 'package:bird_music/Data/class.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  var _filePath = '';
  final List<String> _readFolders = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 630;
    final width = screenWidth * 0.1;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Map<String, List<String>>>(
        future: readFolders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
            return const Center(child: Text('No data available'));
          } else {
            final title1 = snapshot.data?['文件管理'];
            final title2 = snapshot.data?['背景管理'];
            final title3 = snapshot.data?['封面位置'];
            return Column(children: [
              FolderItem(
                  title: '文件管理',
                  folderPath: title1,
                  width: width,
                  pickFiles: _pickFiles),
              const SizedBox(height: 20),
              FolderItem(
                title: '背景管理',
                folderPath: title2,
                width: width,
                pickFiles: _pickFile,
              ),
              const SizedBox(height: 20),
              FolderItem(
                title: '封面位置',
                folderPath: title3,
                width: width,
                pickFiles: _pickFile,
              )
            ]);
          }
        },
      ),
    );
  }

  // 保存路径
  Future<void> saveFolder(String folderName, String folderPath) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final filePath = p.join(directory.path, 'folders.json');
      final file = File(filePath);
      final folderMap = await readFolders();

      // 直接更新或添加新的路径
      folderMap[folderName] = [folderPath];

      // 写入文件
      await file.writeAsString(json.encode(folderMap));
    } catch (e) {
      debugPrint("Error saving folder: $e");
    }
    //重绘页面
    setState(() {});
  }

  // 读取路径
  Future<Map<String, List<String>>> readFolders() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final filePath = p.join(directory.path, 'folders.json');
      final file = File(filePath);

      if (await file.exists()) {
        final folderJson = await file.readAsString();
        if (folderJson.isEmpty) {
          return {};
        }
        final Map<String, dynamic> playlistMaps = json.decode(folderJson);
        return playlistMaps
            .map((key, value) => MapEntry(key, List<String>.from(value)));
      }
    } catch (e) {
      debugPrint("Error reading folders: $e");
    }
    return {};
  }

  // 选择文件
  Future<void> _pickFile(String folderName) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final String newFilePath = result.files.single.path!;
      // 先保存路径
      await saveFolder(folderName, newFilePath);
      // 检查组件是否仍然挂载
      if (mounted) {
        setState(() {
          _filePath = newFilePath;
          debugPrint('_filePath: $_filePath');
        });

        // 然后再通知 UI 更新
        Provider.of<PicturePathProvider>(context, listen: false)
            .updatePicturePath();
      }
    } else {
      if (mounted) {
        // 检查组件是否仍然挂载
        setState(() {
          _filePath = 'File picking cancelled';
        });
      }
    }
  }

  // 选择文件夹
  Future<void> _pickFiles(String folderName) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _filePath = selectedDirectory;
        _readFolders.add(_filePath);
        debugPrint("_filePath: $_filePath");
        saveFolder(folderName, _filePath);
      });
    } else {
      setState(() {
        _filePath = 'Directory picking cancelled';
      });
    }
  }
}

class FolderItem extends StatelessWidget {
  final String title;
  final List<String>? folderPath;
  final double width;
  final Function pickFiles;

  const FolderItem({
    required this.title,
    required this.folderPath,
    required this.width,
    required this.pickFiles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 30),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: width),
        Expanded(
          child: Text(
            '$folderPath',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: width),
        ElevatedButton(
          onPressed: () {
            pickFiles(title);
          },
          child: Text('选择$title'),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
