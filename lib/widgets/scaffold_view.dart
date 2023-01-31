import 'package:flutter/material.dart';
import 'package:nae_hr/core/platform.dart';
import 'package:nae_hr/widgets/copy_to_clipboard.dart';

class ScaffoldView extends StatelessWidget {
  // final BaseEntity entity;
  final PreferredSizeWidget? appBarBottom;
  final Widget body;

  ScaffoldView({super.key,
    required this.body,
    // required this.entity,
    this.appBarBottom,
  });

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "";

    Widget leading = IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        // TODO close
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        leading: leading,
        automaticallyImplyLeading: isMobile(context),
        centerTitle: false,
        title: CopyToClipboard(
          value: appBarTitle,
          child: Text(appBarTitle),
        ),
        bottom: appBarBottom,
      ),
      body: SafeArea(
        child: body,
      )
    );
  }
}