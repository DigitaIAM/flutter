
import 'package:flutter/widgets.dart';
import 'package:nae_hr/widgets/copy_to_clipboard.dart';

class IconText extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final MainAxisAlignment alignment;
  final TextStyle? style;
  final bool copyToClipboard;

  const IconText({super.key,
    required this.icon, required this.text,
    this.alignment = MainAxisAlignment.start,
    this.style,
    this.copyToClipboard = false
  });

  @override
  Widget build(BuildContext context) {
    Widget textWidget;
    if (copyToClipboard && text != null) {
      textWidget = CopyToClipboard(
          value: text,
          child: Text(
            text ?? '',
            style: style,
            overflow: TextOverflow.ellipsis,
          )
      );
    } else {
      textWidget = Text(
        text ?? '',
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget> [
        Icon(icon, color: style?.color),
        const SizedBox(width: 10),
        Flexible(
          child: textWidget,
        )
      ]
    );
  }
}