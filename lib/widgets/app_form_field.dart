
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DecoratedFormField extends StatefulWidget {
  const DecoratedFormField({super.key,
    required this.name,
    this.label,
    this.focusNode, this.autofocus = false,
    required this.validator,  required this.keyboardType,
    this.expands = false, this.minLines = 1, this.maxLines = 1,
    this.decoration,
    required this.onSave,
  });

  final String name;
  final String? label;

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
  State<DecoratedFormField> createState() => _DecoratedFormFieldState();

}

class _DecoratedFormFieldState extends State<DecoratedFormField> {

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
          // hintText: widget.hint ?? '',
          // border: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          // ),
          // suffixIcon: suffixIcon,
          floatingLabelBehavior: (widget.label ?? '').isEmpty
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.auto
      );
    }

    return FormBuilderTextField(
      name: widget.name,
      // decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("label")),
      decoration: inputDecoration!,
      style: Theme.of(context).textTheme.bodyMedium,

      validator: widget.validator,
      // autovalidateMode: AutovalidateMode.onUserInteraction,

      focusNode: widget.focusNode,
      autofocus: widget.autofocus,

      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.next,

      onEditingComplete: () {
        print("onEditingComplete");
      },
      onSubmitted: (value) {
        print("onSubmitted");
        print(value);
      }

      // key: ValueKey(widget.label),
      // controller: widget.controller,

      // maxLines: widget.expands ? null : widget.maxLines,
      // minLines: widget.expands ? null : widget.minLines,
      // expands: widget.expands,
      // onChanged: (value) {
      //   _showClear = value.isNotEmpty;
      // },
      // onFieldSubmitted: (value) {
      //   widget.onSave?.call(context);
      // },
    );
  }

}