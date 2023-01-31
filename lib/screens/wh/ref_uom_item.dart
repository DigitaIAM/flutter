import 'package:flutter/material.dart';

import '../../model/memory/item.dart';

class UomListItem extends StatelessWidget {
  const UomListItem({super.key, required this.item});

  final MemoryItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${item.id}', style: textTheme.caption),
        title: Text(item.json['label'] ?? ""),
        isThreeLine: true,
        subtitle: Text('subtitle'),
        dense: true,
      ),
    );
  }
}
