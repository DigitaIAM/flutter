import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class AppForm extends StatelessWidget {
  const AppForm(
      {super.key,
      required this.formKey,
      required this.entity,
      required this.focusNode,
      this.onChanged,
      this.child,
      this.children,
      this.schema = const []});

  final GlobalKey<FormBuilderState> formKey;
  final MemoryItem entity;
  final List<Field> schema;
  final FocusScopeNode focusNode;

  final VoidCallback? onChanged;

  // should be one of
  final Widget? child;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MemoryItem>(
      future: entity.enrich(schema),
      builder: (BuildContext context, AsyncSnapshot<MemoryItem> snapshot) {
        if (snapshot.hasData) {
          return FocusScope(
            node: focusNode,
            child: FormBuilder(
              key: formKey,
              initialValue: snapshot.data!.json,
              autovalidateMode: AutovalidateMode.disabled,
              skipDisabled: true,
              onChanged: onChanged,
              child: child ??
                  ScrollableListView(
                    primary: true,
                    children: children!,
                  ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

class EnrichmentParams {
  final String field;
  final List<String> ctx;

  EnrichmentParams(this.field, this.ctx);
}
