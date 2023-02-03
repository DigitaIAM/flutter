
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

class AppForm extends StatelessWidget {
  const AppForm({super.key,
    required this.formKey, required this.entity, required this.focusNode,
    this.child, this.children
  });

  final GlobalKey<FormBuilderState> formKey;
  final MemoryItem entity;
  final FocusScopeNode focusNode;

  // should be one of
  final Widget? child;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: focusNode,
      child: FormBuilder(
        key: formKey,
        initialValue: entity.json,
        autovalidateMode: AutovalidateMode.disabled,
        skipDisabled: true,
        // onChanged: () {
        //   formKey.currentState!.save();
        //   debugPrint("onChanged: ${formKey.currentState!.value}");
        // },
        child: child ?? ScrollableListView(
          primary: true,
          children: children!,
        ),
      ),
    );
  }
}