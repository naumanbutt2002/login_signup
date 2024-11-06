import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final String iconPath;

  const CustomIcon({
    super.key,
    required this.iconPath,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      height: size,
      width: size,
      color: color,
    );
  }
}
