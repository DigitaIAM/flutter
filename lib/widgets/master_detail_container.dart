import 'package:flutter/material.dart';
import 'package:nae_hr/layout/adaptive.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/widgets/item_details.dart';

class MasterDetailContainer extends StatefulWidget {
  const MasterDetailContainer({super.key, required this.title, required this.masterBuilder, required this.detailsBuilder});

  final String title;
  final MasterBuilder masterBuilder;
  final DetailsBuilder detailsBuilder;

  @override
  _MasterDetailContainerState createState() => _MasterDetailContainerState();
}

class _MasterDetailContainerState extends State<MasterDetailContainer> {

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isDisplayDesktop(context)) {
      content = _buildTabletLayout();
    } else {
      content = _buildMobileLayout();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: content,
    );
  }

  Widget _buildMobileLayout() {
    return widget.masterBuilder.build(context);
  }

  Widget _buildTabletLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
            elevation: 4.0,
            child: widget.masterBuilder.build(context),
          ),
        ),
        if (widget.detailsBuilder.selected != null)
          Flexible(
            flex: 1,
            child: Column(
              children: <Widget>[
                ItemDetails(
                  isDesktopLayout: true,
                  builder: widget.detailsBuilder,
                  item: widget.detailsBuilder.selected!,
                ),
              ]
            ),
          ),
      ],
    );
  }
}

typedef MasterContentBuilder = Widget Function(BuildContext context);

class MasterBuilder {

  MasterBuilder({required this.builder});

  final MasterContentBuilder builder;

  Widget build(BuildContext context) {
    return builder(context);
  }
}

typedef DetailsContentBuilder = List<Widget> Function(BuildContext context, MemoryItem item);

class DetailsBuilder {

  DetailsBuilder({required this.builder, required this.selected});

  final MemoryItem? selected;
  final DetailsContentBuilder builder;

  List<Widget> build(BuildContext context, MemoryItem item) {
    return builder(context, item);
  }
}