import 'package:flutter/material.dart';
import 'package:nae/constants.dart';

class SearchText extends StatelessWidget {
  const SearchText(
      {super.key,
      required this.filterController,
      required this.focusNode,
      required this.onChanged,
      required this.onCleared,
      this.placeholder});

  final TextEditingController filterController;
  final FocusNode focusNode;

  final Function(String) onChanged;
  final Function onCleared;

  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 8.0),
      height: 40,
      margin: const EdgeInsets.only(bottom: 2.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900, // TODO Theme.of(context).appBarTheme.toolbarTextStyle?.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(cBorderRadius)),
      ),
      child: TextField(
        focusNode: focusNode,
        textAlign: filterController.text.isNotEmpty || focusNode.hasFocus ? TextAlign.start : TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
          suffixIcon: filterController.text.isNotEmpty || focusNode.hasFocus
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  onPressed: () {
                    filterController.text = '';
                    focusNode.unfocus(disposition: UnfocusDisposition.previouslyFocusedChild);
                    onCleared();
                  },
                )
              : Icon(Icons.search, color: theme.textTheme.bodyLarge?.color),
          border: InputBorder.none,
          hintText: focusNode.hasFocus ? '' : placeholder ?? '',
        ),
        autocorrect: false,
        onChanged: (value) => onChanged(value),
        controller: filterController,
      ),
    );
  }
}
