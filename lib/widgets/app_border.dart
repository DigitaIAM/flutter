
import 'package:flutter/material.dart';
import 'package:nae_hr/constants.dart';



class AppBorder extends StatelessWidget {
  final Widget child;

  final bool? isTop;
  final bool? isBottom;
  final bool? isLeft;

  final bool? hide;

  const AppBorder({super.key, required this.child, this.isTop, this.isBottom, this.isLeft, this.hide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const borderWidth = cIsWeb ? 2.0 : 1.5;
    final isAllSides = isTop == null && isLeft == null; // TODO review

    final color = theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius:
        isAllSides ? BorderRadius.circular(cBorderRadius) : null,
        border: isAllSides ? Border.all(width: borderWidth, color: color) : Border(
          top: isTop == true ? BorderSide(width: borderWidth, color: color) : BorderSide.none,
          bottom: isBottom == true ? BorderSide(width: borderWidth, color: color) : BorderSide.none,
          left: isLeft == true ? BorderSide(width: borderWidth, color: color) : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

}