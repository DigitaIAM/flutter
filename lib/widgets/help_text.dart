import 'package:flutter/material.dart';

class HelpText extends StatelessWidget {
  final String message;

  const HelpText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.8,
        child: Text(
          message,
          style: const TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}