import 'package:flutter/material.dart';

class NewBox extends StatelessWidget {
  final double bWidth;
  final double bHeight;
  const NewBox({super.key, required this.bWidth, required this.bHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bWidth,
      height: bHeight,
      decoration: const BoxDecoration(
        color: Colors.black, // 使用常量颜色
        borderRadius: BorderRadius.all(Radius.circular(12)), // 使用常量圆角
        boxShadow: [
          BoxShadow(
            color: Colors.grey, // 使用常量颜色
            blurRadius: 15,
            offset: Offset(5, 5),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 15,
            offset: Offset(-5, -5),
          )
        ],
      ),
    );
  }
}
