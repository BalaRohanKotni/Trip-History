import 'package:flutter/material.dart';

class GraphLayoutDelegate extends MultiChildLayoutDelegate {
  GraphLayoutDelegate({required this.position});
  final Offset position;

  @override
  void performLayout(Size size) {
    if (hasChild(2)) {
      final secondSize = layoutChild(
        2,
        BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height,
        ),
      );
      final firstSize = layoutChild(
        1,
        BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height,
        ),
      );

      positionChild(
        1,
        Offset(
          secondSize.width - firstSize.width,
          size.height / 1 - secondSize.height / 1,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(GraphLayoutDelegate oldDelegate) {
    return oldDelegate.position != position;
  }
}
