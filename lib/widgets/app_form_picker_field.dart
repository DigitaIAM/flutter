import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nae_hr/api.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/widgets/form_builder_searchable_dropdown.dart';

class DecoratedFormPickerField extends StatefulWidget {
  const DecoratedFormPickerField({
    super.key,
    required this.ctx,
    required this.name,
    this.label,
    this.focusNode,
    this.autofocus = false,
    required this.validator,
    this.expands = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.decoration,
    required this.onSave,
    this.keepAsID = true,
  });

  final List<String> ctx;
  final String name;
  final String? label;

  final FocusNode? focusNode;
  final bool autofocus;
  final FormFieldValidator<String> validator;

  final bool expands;
  final int minLines;
  final int maxLines;

  final InputDecoration? decoration;
  final Function(BuildContext)? onSave;

  final bool keepAsID;

  @override
  State<DecoratedFormPickerField> createState() => _DecoratedFormPickerFieldState();
}

class _DecoratedFormPickerFieldState extends State<DecoratedFormPickerField> {
  @override
  Widget build(BuildContext context) {
    final label = widget.label ?? '';
    InputDecoration inputDecoration = widget.decoration ??
        InputDecoration(
            labelText: label,
            floatingLabelBehavior: label.isEmpty ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto);
    return FormBuilderSearchableDropdown<MemoryItem>(
      name: widget.name,
      popupProps: const PopupProps.menu(showSearchBox: true),
      // decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("label")),
      decoration: inputDecoration,
      // TODO style: Theme.of(context).textTheme.bodyMedium,
      // validator: widget.validator,
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      compareFn: (a, b) => a.id == b.id,
      asyncItems: (filter) async {
        print("filter: $filter");
        final response = await Api.feathers()
            .find(serviceName: "memories", query: {"oid": Api.instance.oid, "ctx": widget.ctx, "\$search": filter});
        return (response['data'] ?? []).map<MemoryItem>((item) => MemoryItem.from(item)).toList();
      },
      itemAsString: (MemoryItem? item) {
        return item?.name() ?? '';
      },

      valueTransformer: (MemoryItem? item) {
        if (widget.keepAsID) {
          return item?.id;
        } else {
          return item?.json;
        }
      },
      focusNode: widget.focusNode,
    );
  }
}
