
import 'package:flutter/material.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

class AppForm extends StatelessWidget {
  const AppForm({super.key,
    required this.formKey, required this.focusNode,
    this.child, this.children
  });

  final GlobalKey<FormState> formKey;
  final FocusScopeNode focusNode;

  // should be one of
  final Widget? child;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: focusNode,
      child: Form(
        key: formKey,
        child: child ??
            ScrollableListView(
              primary: true,
              children: children!,
            ),
      ),
    );
  }

}