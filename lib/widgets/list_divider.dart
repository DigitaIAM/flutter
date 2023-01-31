
import 'package:flutter/material.dart';

class ListDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const color = Colors.red; // TODO change to use theme

    return Container(
      color: color,
      child: const Divider(
        color: color,
        thickness: 1.5,
        height: 1.5,
      ),
    );
  }
}