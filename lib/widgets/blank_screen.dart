
import 'package:flutter/material.dart';
import 'package:nae_hr/core/platform.dart';
import 'package:nae_hr/widgets/help_text.dart';

class BlankScreen extends StatelessWidget {
  final String? message;

  const BlankScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: isMobile(context),
      ),
      body: Container(
        color: Theme.of(context).cardColor,
        child: HelpText(message: message ?? ''),
      ),
    );
  }

}