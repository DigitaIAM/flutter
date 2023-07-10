import 'package:flutter/material.dart';

class DeleteButton extends StatefulWidget {
  const DeleteButton({super.key, required this.status, required this.onChanged});

  final String? status;
  final Function(bool) onChanged;

  @override
  State<StatefulWidget> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();

    if (widget.status == 'deleted') {
      isChecked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = isChecked ? 'restore' : 'delete';

    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
      ),
      onPressed: () {
        setState(() {
          isChecked = !isChecked;

          widget.onChanged(isChecked);
        });
      },
      child: Text(buttonText),
    );
  }
}
