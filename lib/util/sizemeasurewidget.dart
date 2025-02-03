import 'package:flutter/material.dart';

class SizeMeasureWidget extends StatefulWidget {
  final Function(Size?, BoxConstraints) onSizeMeasured;
  final Widget child;

  const SizeMeasureWidget(
      {super.key, required this.onSizeMeasured, required this.child});

  @override
  State<SizeMeasureWidget> createState() => _SizeMeasureWidgetState();
}

class _SizeMeasureWidgetState extends State<SizeMeasureWidget> {
  final GlobalKey _sizeKey = GlobalKey();
  Size? size;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return Container(
        key: _sizeKey,
        child: widget.child,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSize();
    });
  }

  void _getSize() {
    RenderBox renderBox =
        _sizeKey.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    this.size = size;
    widget.onSizeMeasured(size, renderBox.constraints);
  }
}
