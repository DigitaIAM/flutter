
import 'package:flutter/material.dart';

class ChangeLayoutBanner extends StatefulWidget {
  final Widget child;

  const ChangeLayoutBanner({super.key, required this.child});

  @override
  _ChangeLayoutBannerState createState() => _ChangeLayoutBannerState();

}

class _ChangeLayoutBannerState extends State<ChangeLayoutBanner> {
  @override
  Widget build(BuildContext context) {
    // TODO detect size and ratio changes
    return SafeArea(
        child: Column(
          children: [
            // AnimatedContainer(),
            Expanded(
              child: widget.child,
            )
          ]
        )
    );
  }

}