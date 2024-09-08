import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatefulWidget implements PreferredSizeWidget {
  final bool? songpage;
  final bool? setting;
  const TitleBar({super.key, this.songpage = false, this.setting = false});

  @override
  TitleBarState createState() => TitleBarState();

  @override
  Size get preferredSize => const Size.fromHeight(55);
}

class TitleBarState extends State<TitleBar> {
  final ValueNotifier<bool> isMaximizedNotifier = ValueNotifier<bool>(false);
  bool _isHovered = false;
  bool _isHoveredsetting = false;
  bool _isHoveredMinimize = false;
  bool _isHoveredMaximize = false;
  bool _isHoveredClose = false;

  @override
  void initState() {
    super.initState();
    _initIsMaximized();
  }

  Future<void> _initIsMaximized() async {
    try {
      isMaximizedNotifier.value = await windowManager.isMaximized();
    } catch (e) {
      debugPrint("Error initializing maximized state: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      color: Colors.transparent,
      child: Stack(
        children: [
          DragToMoveArea(
            child: Container(
              width: double.infinity,
              height: 55,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: 15,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.setting!
                    ? InkWell(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/setting'),
                        splashColor: Colors.transparent, // 去掉水波效果
                        highlightColor: Colors.transparent, // 去掉高亮效果
                        hoverColor: Colors.transparent, // 去掉悬停效果
                        onHover: (hovering) {
                          setState(() {
                            _isHoveredsetting = hovering;
                          });
                        },
                        child: Image.asset(
                          'assets/image/设置.png',
                          width: 25,
                          height: 25,
                          color:
                              (_isHoveredsetting ? Colors.white : Colors.grey),
                        ),
                      )
                    : const SizedBox(width: 25), // 增加图标之间的空隙
                const SizedBox(width: 10), // 增加图标之间的空隙
                InkWell(
                  onTap: () => windowManager.minimize(),
                  splashColor: Colors.transparent, // 去掉水波效果
                  highlightColor: Colors.transparent, // 去掉高亮效果
                  hoverColor: Colors.transparent, // 去掉悬停效果
                  onHover: (hovering) {
                    setState(() {
                      _isHoveredMinimize = hovering;
                    });
                  },
                  child: Image.asset(
                    'assets/image/minimize.png',
                    width: 25,
                    height: 25,
                    color: (_isHoveredMinimize ? Colors.white : Colors.grey),
                  ),
                ),
                const SizedBox(width: 10), // 增加图标之间的空隙
                ValueListenableBuilder<bool>(
                  valueListenable: isMaximizedNotifier,
                  builder: (context, isMaximized, child) {
                    return InkWell(
                      onTap: () =>
                          isMaximized ? _unmaximizeWindow() : _maximizeWindow(),
                      splashColor: Colors.transparent, // 去掉水波效果
                      highlightColor: Colors.transparent, // 去掉高亮效果
                      hoverColor: Colors.transparent, // 去掉悬停效果
                      onHover: (hovering) {
                        setState(() {
                          _isHoveredMaximize = hovering;
                        });
                      },
                      child: Image.asset(
                        isMaximized
                            ? 'assets/image/maximize.png'
                            : 'assets/image/full_screen.png',
                        width: 25,
                        height: 25,
                        color:
                            (_isHoveredMaximize ? Colors.white : Colors.grey),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10), // 增加图标之间的空隙
                InkWell(
                  onTap: () => windowManager.close(),
                  splashColor: Colors.transparent, // 去掉水波效果
                  highlightColor: Colors.transparent, // 去掉高亮效果
                  hoverColor: Colors.transparent, // 去掉悬停效果
                  onHover: (hovering) {
                    setState(() {
                      _isHoveredClose = hovering;
                    });
                  },
                  child: Image.asset(
                    'assets/image/shut.png',
                    width: 25,
                    height: 25,
                    color: (_isHoveredClose ? Colors.white : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Stack(
                children: [
                  widget.songpage!
                      ? InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          splashColor: Colors.transparent, // 去掉水波效果
                          highlightColor: Colors.transparent, // 去掉高亮效果
                          hoverColor: Colors.transparent, // 去掉悬停效果
                          onHover: (hovering) {
                            setState(() {
                              _isHovered = hovering;
                            });
                          },
                          child: Image.asset(
                            'assets/image/下箭头.png',
                            width: 50,
                            height: 50,
                            color: (_isHovered ? Colors.white : Colors.grey),
                          ),
                        )
                      : const SizedBox(width: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unmaximizeWindow() async {
    // try {
    await windowManager.unmaximize();
    isMaximizedNotifier.value = false;
    // } catch (e) {
    //   debugPrint("Error unmaximizing window: $e");
    // }
  }

  Future<void> _maximizeWindow() async {
    // try {
    await windowManager.maximize();
    isMaximizedNotifier.value = true;
    // } catch (e) {
    //   debugPrint("Error maximizing window: $e");
    // }
  }

  // Future<void> _minimizeWindow() async {
  //   try {
  //     await windowManager.minimize();
  //   } catch (e) {
  //     debugPrint("Error minimizing window: $e");
  //   }
  // }

  // Future<void> _closeWindow() async {
  //   try {
  //     await windowManager.close();
  //   } catch (e) {
  //     debugPrint("Error closing window: $e");
  //   }
  // }
}
