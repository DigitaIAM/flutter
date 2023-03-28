import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AutocompleteField<T extends Object> extends StatefulWidget {
  const AutocompleteField({
    super.key,
    this.label,
    required this.initialValue,
    required this.create,
    required this.delegate,
    required this.displayStringForOption,
    required this.itemBuilder,
    required this.onItemSelected,
    this.autofocus = false,
    this.focusNode,
    this.decoration,
    this.keyboardType = TextInputType.text,
    this.editable = true,
  });

  final String? label;
  final T? initialValue;

  final bool editable;

  final InputDecoration? decoration;
  final String Function(T?) displayStringForOption;
  final Widget Function(BuildContext context, T entry) itemBuilder;
  final Future<T> Function(String) create;
  final Future<Iterable<T>> Function(String) delegate;
  final Function(T? entry) onItemSelected;

  final bool autofocus;
  final FocusNode? focusNode;

  final TextInputType keyboardType;

  @override
  State<StatefulWidget> createState() => _AutocompleteFieldState<T>();
}

class _AutocompleteFieldState<T extends Object> extends State<AutocompleteField<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  late InputDecoration inputDecoration;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.displayStringForOption(widget.initialValue));
    _controller.addListener(() {
      update();
    });

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_controller.text.isEmpty) {
          widget.onItemSelected(null);
        }
        // widget.onItemSelected(selection);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void update() {
    final text = _controller.text;
    final initial = widget.displayStringForOption(widget.initialValue);
    final isNew = text.isNotEmpty && text != initial;

    // print("update: $isNew ${widget.initialValue}");
    // print("$text vs $initial");

    setState(() {
      inputDecoration = InputDecoration(
        labelText: widget.label,
        border: const UnderlineInputBorder(),
        floatingLabelBehavior:
            widget.label?.isEmpty ?? true ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
        suffixIcon: isNew
            ? IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: () async {
                  final item = await widget.create(text);
                  widget.onItemSelected(item);
                })
            : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    update();

    if (widget.editable) {
      return RawAutocomplete<T>(
          textEditingController: _controller,
          focusNode: _focusNode,
          onSelected: (T selection) {
            print('Selected: $selection');
            widget.onItemSelected(selection);
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: inputDecoration,
            );
          },
          displayStringForOption: widget.displayStringForOption,
          optionsBuilder: (TextEditingValue v) {
            return widget.delegate(v.text);
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
            final theme = Theme.of(context);

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: 200, maxWidth: 600),
                  // color: theme.cardColor,
                  // width: 300,
                  // constraints: const BoxConstraints(maxHeight: 270),
                  child: ListView.builder(
                    // primary: true,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final T option = options.elementAt(index);

                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Builder(builder: (BuildContext context) {
                            final highlightedIndex = AutocompleteHighlightedOption
                                .of(context);
                            final highlight = highlightedIndex == index;
                            if (highlight) {
                              SchedulerBinding.instance.addPostFrameCallback((
                                  Duration timeStamp) {
                                Scrollable.ensureVisible(
                                    context, alignment: 0.5);
                              });
                            }

                            return Container(
                              // theme.primaryColorDark : theme.primaryColorLight,
                              color: highlight ? Theme
                                  .of(context)
                                  .focusColor : null,
                              padding: const EdgeInsets.all(16.0),
                              child: widget.itemBuilder(context, option),
                              // ListTile(
                              //   title: widget.itemBuilder(context, option),
                              //   onTap: () {
                              //     print("onTap $option");
                              //     onSelected(option);
                              //   },
                              // ),
                            );
                          }),
                        );
                      }),
                ),
              ),
            );
          });
    } else {
      return TextField(
        readOnly: true,
        controller: _controller,
//        focusNode: fieldFocusNode,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: inputDecoration,

      );
    }
  }
}
