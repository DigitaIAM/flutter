
import 'package:flutter/material.dart';

class DecoratedFormField extends StatefulWidget {
  const DecoratedFormField({super.key,
    this.label,
    required this.controller,
    this.focusNode, this.autofocus = false,
    required this.validator,  required this.keyboardType,
    this.expands = false, this.minLines = 1, this.maxLines = 1,
    this.decoration,
    this.onChanged, required this.onSave,
  });

  final String? label;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;

  final bool expands;
  final int minLines;
  final int maxLines;

  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final Function(BuildContext)? onSave;

  @override
  State<DecoratedFormField> createState() => _DecoratedFormFieldState();

}

class _DecoratedFormFieldState extends State<DecoratedFormField> {

  bool _showClear = true;

  @override
  Widget build(BuildContext context) {


    InputDecoration? inputDecoration = widget.decoration;
    if (inputDecoration == null && (widget.label != null)) {

      IconButton? suffixIcon;
      if (_showClear) {
        suffixIcon = IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            widget.controller.text = '';
            setState(() {
              _showClear = false;
            });
          },
        );
      }

      inputDecoration = InputDecoration(
          labelText: widget.label ?? '',
          // hintText: widget.hint ?? '',
          suffixIcon: suffixIcon,
          floatingLabelBehavior: (widget.label ?? '').isEmpty
              ? FloatingLabelBehavior.always
              : FloatingLabelBehavior.auto
      );
    }

    return TextFormField(
      key: ValueKey(widget.label),
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: widget.keyboardType,
      maxLines: widget.expands ? null : widget.maxLines,
      minLines: widget.expands ? null : widget.minLines,
      expands: widget.expands,
      onChanged: (value) {
        _showClear = value.isNotEmpty;
        widget.onChanged?.call(value);
      },
      onFieldSubmitted: (value) {
        widget.onSave?.call(context);
      },
      decoration: inputDecoration,
    );
  }

}