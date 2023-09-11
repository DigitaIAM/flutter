import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/widgets/autocomplete.dart';

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
    this.onChange,
    this.creatable = true,
    this.readOnly = false,
  });

  final List<String> ctx;
  final String name;
  final String? label;

  final FocusNode? focusNode;
  final bool autofocus;
  final FormFieldValidator<MemoryItem> validator;

  final bool expands;
  final int minLines;
  final int maxLines;

  final InputDecoration? decoration;
  final Function(BuildContext)? onSave;
  final Function(MemoryItem?)? onChange;

  final bool creatable;
  final bool readOnly;

  @override
  State<DecoratedFormPickerField> createState() => _DecoratedFormPickerFieldState();
}

class _DecoratedFormPickerFieldState extends State<DecoratedFormPickerField> {
  @override
  Widget build(BuildContext context) {
    // InputDecoration inputDecoration = widget.decoration ??
    // InputDecoration inputDecoration = InputDecoration(
    //     labelText: label,
    //     floatingLabelBehavior: label.isEmpty ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto);

    return FormBuilderField<MemoryItem>(
      name: widget.name,
      validator: widget.validator,
      onChanged: (val) => debugPrint("onChanged $val"),
      builder: (FormFieldState field) {
        return Column(
          children: [
            AutocompleteField<MemoryItem>(
              autofocus: widget.autofocus,
              label: widget.label,
              initialValue: field.value,
              creatable: widget.creatable,
              create: (text) async {
                final response = await Api.feathers().create(
                    serviceName: "memories", data: {cName: text}, params: {"oid": Api.instance.oid, "ctx": widget.ctx});
                // print("response: $response");
                return MemoryItem.from(response);
              },
              delegate: (text) async {
                if (field.value != null && field.value.name() != text) {
                  field.didChange(null);
                }
                final response = await Api.feathers()
                    .find(serviceName: "memories", query: {"oid": Api.instance.oid, "ctx": widget.ctx, "search": text});
                return (response['data'] ?? []).map<MemoryItem>((item) => MemoryItem.from(item)).toList();
              },
              displayStringForOption: (item) => item?.name() ?? '',
              itemBuilder: (context, entry) {
                return Text(entry.name(), style: Theme.of(context).textTheme.labelMedium);
              },
              onItemSelected: (entry) {
                // print('onItemSelected $entry');
                field.didChange(entry);
                widget.onChange?.call(entry);
              },
              // decoration: inputDecoration,
            ),
            if (field.hasError)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 10),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(fontStyle: FontStyle.normal, fontSize: 13, color: Colors.red[700], height: 0.5),
                    ),
                  ),
                ],
              )
          ],
        );
      },
    );
    // return FormBuilderSearchableDropdown<MemoryItem>(
    //   name: widget.name,
    //   popupProps: const PopupProps.menu(showSearchBox: true),
    //   // decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("label")),
    //   decoration: inputDecoration,
    //   // TODO style: Theme.of(context).textTheme.bodyMedium,
    //   // validator: widget.validator,
    //   // autovalidateMode: AutovalidateMode.onUserInteraction,
    //   compareFn: (a, b) => a.id == b.id,
    //   asyncItems: (text) async {
    //     print("text: $text");
    //     final response = await Api.feathers()
    //         .find(serviceName: "memories", query: {"oid": Api.instance.oid, "ctx": widget.ctx, "search": text});
    //     return (response['data'] ?? []).map<MemoryItem>((item) => MemoryItem.from(item)).toList();
    //   },
    //   itemAsString: (MemoryItem? item) {
    //     return item?.name() ?? '';
    //   },
    //
    //   valueTransformer: (MemoryItem? item) {
    //     if (widget.keepAsID) {
    //       return item?.id;
    //     } else {
    //       return item?.json;
    //     }
    //   },
    //   focusNode: widget.focusNode,
    // );
  }
}
