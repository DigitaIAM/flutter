import 'package:flutter/material.dart';
import 'package:nae/constants.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_view.dart';

class WHMovementView extends EntityHolder {
  const WHMovementView({super.key, required super.entity});

  @override
  State<WHMovementView> createState() => _WHMovementViewState();
}

class _WHMovementViewState extends State<WHMovementView> {
  @override
  Widget build(BuildContext context) {
    // final store = fStorage.resolve(widget.entity.json);
    // final goods = fGoods.resolve(widget.entity.json);

    return ScaffoldView(
      title: 'Movement report',
      body: Builder(builder: (context) {
        return const Column(children: <Widget>[
          Expanded(
            child: Text("Movement report"),
          ),
        ]);
      }),
    );
  }
}
