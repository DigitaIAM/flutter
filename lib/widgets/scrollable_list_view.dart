
import 'package:flutter/material.dart';

class ScrollableListView extends StatefulWidget {

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool primary;
  final bool showScrollbar;

  const ScrollableListView({super.key, required this.children, this.showScrollbar = false, this.primary = false, this.padding});

  @override
  _ScrollableListViewState createState() => _ScrollableListViewState();
}

class _ScrollableListViewState extends State<ScrollableListView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = null; // widget.primary == true ? null : widget.scrollController ?? _scrollController;

    Widget child = ListView(
      padding: widget.padding,
      controller: controller,
      shrinkWrap: true,
      primary: widget.primary,
      children: widget.children,
    );

    if (widget.showScrollbar) {
      child = Scrollbar(
        controller: controller,
        thumbVisibility: true,
        child: child,
      );
    }

    return child;
  }
}