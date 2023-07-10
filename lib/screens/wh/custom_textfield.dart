import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key, required this.initialValue, required this.onChanged, this.editable = true});

  final dynamic initialValue;
  final Function(String) onChanged;
  final bool editable;

  @override
  State<StatefulWidget> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final _controller = TextEditingController();
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller.text = widget.initialValue?.toString() ?? '';

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        print("lost focus");
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      readOnly: widget.editable ? false : true,
      style: widget.editable ? null : const TextStyle(color: Colors.grey),
    );
  }
}
