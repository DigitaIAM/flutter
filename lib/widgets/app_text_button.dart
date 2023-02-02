
import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({super.key,
    required this.label, required this.onPressed,
    this.isHeader = false,
  });

  final String label;
  final void Function()? onPressed;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color primaryColor = isHeader ? theme.primaryColorLight : theme.primaryColorDark;
    final ButtonStyle style = TextButton.styleFrom(foregroundColor: primaryColor);

    return TextButton(
      style: style,
      onPressed: onPressed,
      child: Text(label),
    );
  }

}