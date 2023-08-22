import 'package:flutter/material.dart';

class ListDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = theme.primaryColorDark;

    return Container(
      color: color,
      child: Divider(
        color: color,
        thickness: 1.5,
        height: 1.5,
      ),
    );
  }
}
