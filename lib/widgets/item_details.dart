import 'package:flutter/material.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/widgets/master_detail_container.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails({super.key,
    required this.isDesktopLayout,
    required this.builder,
    required this.item,
  });

  final bool isDesktopLayout;
  final DetailsBuilder builder;
  final MemoryItem item;

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: builder.builder(context, item)
    );

    if (isDesktopLayout) {
      return Center(child: content);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit unit of measure"),
      ),
      body: Center(child: content),
    );
  }
}