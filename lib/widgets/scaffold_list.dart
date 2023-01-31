import 'package:flutter/material.dart';

class ScaffoldList extends StatelessWidget {
  final Widget body;

  const ScaffoldList({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // store.dispatch(ViewDashboard());
          return false;
        },
        child: Scaffold(
          body: ClipRect(
            child: body,
          ),
        )
    );
  }
}