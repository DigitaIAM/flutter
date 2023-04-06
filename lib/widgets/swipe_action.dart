import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum SwipeAction { print, delete }

class SwipeActionWidget<T> extends StatelessWidget {
  final Widget child;
  final Function(SwipeAction action) onDismissed;

  const SwipeActionWidget({
    super.key,
    required this.child,
    required this.onDismissed,
    //   Key? key,
    // }) : super(key: key);
  });

  @override
  Widget build(BuildContext context) => Slidable(
        key: const ValueKey(0),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
                onPressed: onDismissed(SwipeAction.delete),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'delete'),
            SlidableAction(
                onPressed: onDismissed(SwipeAction.print),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.print,
                label: 'print'),
          ],
        ),
        child: child,
      );
}
