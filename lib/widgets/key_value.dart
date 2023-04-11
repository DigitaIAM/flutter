import 'package:flutter/material.dart';

class KeyValue extends StatelessWidget {
  final String label;
  final String value;
  final Icon icon;

  const KeyValue({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        // icon: icon,
        labelText: label,
        // labelStyle: const TextStyle(
        //   color: Color(0xFF6200EE),
        // ),
        // helperText: 'Helper text',
        // suffixIcon: const Icon(
        //   Icons.check_circle,
        // ),
        // enabledBorder: const UnderlineInputBorder(
        //   borderSide: BorderSide(color: Color(0xFF6200EE)),
        // ),
      ),
    );
  }
}
