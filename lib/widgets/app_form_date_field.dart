import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class DateField extends StatefulWidget {
  const DateField({
    super.key,
    required this.name,
    this.label,
    this.focusNode,
    this.autofocus = false,
    required this.validator,
    required this.keyboardType,
    this.expands = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.decoration,
    required this.onSave,
    this.readOnly = false,
  });

  final String name;
  final String? label;

  final bool readOnly;

  final FocusNode? focusNode;
  final bool autofocus;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;

  final bool expands;
  final int minLines;
  final int maxLines;

  final InputDecoration? decoration;
  final Function(BuildContext)? onSave;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  // bool _showClear = true;

  @override
  Widget build(BuildContext context) {
    // TODO _showClear = widget.controller.text.isNotEmpty;

    InputDecoration? inputDecoration = widget.decoration;
    if (inputDecoration == null && (widget.label != null)) {
      // IconButton? suffixIcon;
      // if (_showClear) {
      //   suffixIcon = IconButton(
      //     icon: const Icon(Icons.clear),
      //     onPressed: () {
      //       // TODO widget.controller.text = '';
      //       // setState(() {
      //       //   _showClear = false;
      //       // });
      //     },
      //   );
      // }

      inputDecoration = InputDecoration(
        labelText: widget.label ?? '',
        border: const UnderlineInputBorder(),
        // hintText: widget.hint ?? '',
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        // ),
        floatingLabelBehavior:
            widget.label?.isEmpty ?? true ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
        // suffixIcon: suffixIcon,
      );
    }

    return FormBuilderDateTimePicker(
      name: widget.name,
      // decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("label")),
      decoration: inputDecoration!,

      format: DateFormat.yMMMMd('ru'),
      valueTransformer: (text) {
        // print('valueTransformer $text');
        return text;
      },

      // initialValue: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      inputType: InputType.date,

      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.next,
      // onEditingComplete: () {
      //   print("onEditingComplete");
      // },
      // onSubmitted: (value) {
      //   print("onSubmitted");
      //   print(value);
      // },
    );
  }
}
