import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  final Widget body;
  final Widget? title;

  const Screen({Key? key, required this.body, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      // drawer: AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: body,
        ),
      ),
    );
  }
}