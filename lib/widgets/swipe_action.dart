import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nae/models/memory/item.dart';

class ItemAction {
  final String? label;
  final IconData icon;
  final Color? foregroundColor;
  final Color? backgroundColor;

  final void Function(BuildContext context, MemoryItem item) onPressed;

  ItemAction({
    required this.onPressed,
    this.label,
    required this.icon,
    this.foregroundColor,
    this.backgroundColor,
  });
}

class SwipeActionWidget<T> extends StatelessWidget {
  final MemoryItem item;
  final Widget child;
  final List<ItemAction> actions;

  const SwipeActionWidget({
    super.key,
    required this.item,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => Slidable(
        key: const ValueKey(0),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          // dismissible: DismissiblePane(
          //     onDismissed: () => this.onDismissed(SwipeAction.print)),
          children: [
            ...actions.map((action) {
              return SlidableAction(
                onPressed: (context) => action.onPressed(context, item),
                foregroundColor: action.foregroundColor ?? Colors.white,
                backgroundColor: action.backgroundColor ?? Colors.blue,
                icon: action.icon,
                label: action.label,
              );
            })
          ],
        ),
        child: child,
      );
}
