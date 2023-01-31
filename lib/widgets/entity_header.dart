
import 'package:flutter/material.dart';
import 'package:nae_hr/widgets/copy_to_clipboard.dart';

class EntityHeader extends StatelessWidget {

  final String label;
  final String? value;

  const EntityHeader({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title(context))
            ]
          )
        ]
      )
    );
  }

  Widget title(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyText1!;

    return CopyToClipboard(
      value: value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label,
              style: text.copyWith(
                fontSize: 16.0,
                color: text.color!.withOpacity(.65),
              )),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              (value ?? '').isEmpty ? ' ' : value!,
              style: text.copyWith(fontSize: 30),
            ),
          )
        ]
      )
    );
  }
}