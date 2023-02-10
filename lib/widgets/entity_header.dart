import 'package:flutter/material.dart';
import 'package:nae_hr/widgets/copy_to_clipboard.dart';

class Pair {
  final String label;
  final String value;

  Pair(this.label, this.value);
}

class EntityHeader extends StatelessWidget {
  final List<Pair> pairs;

  const EntityHeader({super.key, required this.pairs});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 25),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Row(crossAxisAlignment: CrossAxisAlignment.start, children: generate(context))]));
  }

  List<Widget> generate(BuildContext context) {
    final List<Widget> widgets = [];
    List.generate(pairs.length, (i) {
      final pair = pairs[i];
      if (i > 0) {
        widgets.add(const SizedBox(width: 8));
      }
      widgets.add(Expanded(child: title(context, pair.label, pair.value)));
    });
    return widgets;
  }

  Widget title(BuildContext context, String label, String value) {
    final text = Theme.of(context).textTheme.bodyLarge!;

    return CopyToClipboard(
        value: value,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(label,
              style: text.copyWith(
                fontSize: 16.0,
                color: text.color!.withOpacity(.65),
              )),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              (value ?? '').isEmpty ? ' ' : value,
              style: text.copyWith(fontSize: 30),
            ),
          )
        ]));
  }
}
