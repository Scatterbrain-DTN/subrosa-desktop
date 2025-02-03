import 'package:flutter/material.dart';

class GroupPathElement extends CustomClipper<Path> {
  final double pad;

  const GroupPathElement({this.pad = 20.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addPolygon([
      Offset(pad, size.height / 2.0),
      Offset(0, size.height),
      Offset(size.width - pad, size.height),
      Offset(size.width, size.height / 2.0),
      Offset(size.width - pad, 0),
      Offset(0, 0),
    ], true);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
