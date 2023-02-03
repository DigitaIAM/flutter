import 'package:flutter/material.dart';

class MyDropdownButton<T> extends StatelessWidget {
  final String? labelText;
  final T? value;
  final void Function(T?) onChanged;
  final List<DropdownMenuItem<T>> items;

  final String? blankLabel;
  final T? blankValue;

  final bool showBlank;

  final DropdownButtonBuilder? selectedItemBuilder;
  final bool enabled;

  const MyDropdownButton(
      {super.key,
      this.labelText,
      required this.value,
      required this.onChanged,
      required this.items,
      this.selectedItemBuilder,
      this.blankLabel,
      this.blankValue,
      this.showBlank = false,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = value == null || value == '';

    Widget dropDownButton = DropdownButtonHideUnderline(
        child: DropdownButton<T>(
      value: value,
      isExpanded: true,
      isDense: labelText != null,
      onChanged: enabled ? onChanged : null,
      selectedItemBuilder: selectedItemBuilder,
      items: [
        if (showBlank || isEmpty)
          DropdownMenuItem<T>(
            value: blankValue,
            child: blankLabel == null ? const SizedBox() : Text(blankLabel!),
          ),
        ...items
      ],
    ));

    if (labelText != null) {
      dropDownButton = InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
          ),
          isEmpty: isEmpty && blankLabel == null,
          child: dropDownButton);
    }

    return dropDownButton;
  }
}
