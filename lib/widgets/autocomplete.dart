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
    this.creatable = true,
    this.editable = true,
    this.deleted = false,
  });

  final String? label;
  final T? initialValue;

  final bool creatable;
  final bool editable;
  final bool deleted;

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

  late T? initialValue;
  late T? selected;

  @override
  void initState() {
    super.initState();

    initialValue = widget.initialValue;
    selected = widget.initialValue;

    _controller = TextEditingController(text: widget.displayStringForOption(widget.initialValue));
    _controller.addListener(() {
      update();
    });

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (selected == null || _controller.text != widget.displayStringForOption(selected)) {
          updateSelection(null);
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

  void updateSelection(T? selection) {
    // print('Selected: $selection');
    if (selection == null) {
      _controller.text = '';
      // _controller.text = widget.displayStringForOption(selected);
    }
    selected = selection;
    widget.onItemSelected(selection);
    _controller.text = widget.displayStringForOption(selected);
    // print("_controller.text ${_controller.text}");
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
        suffixIcon: isNew && widget.editable && widget.creatable
            ? IconButton(
                icon: const Icon(Icons.add_box_outlined),
                onPressed: () async {
                  final item = await widget.create(text);
                  updateSelection(item);
                })
            : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // workaround to update controller on change of initial value
    if (initialValue != widget.initialValue) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        setState(() {
          // print("initialValue ${widget.initialValue} vs $initialValue");
          initialValue = widget.initialValue;
          updateSelection(widget.initialValue);
        });
      });
    }

    update();

    if (widget.editable && !widget.deleted) {
      return RawAutocomplete<T>(
          textEditingController: _controller,
          focusNode: _focusNode,
          onSelected: updateSelection,
          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              // style: const TextStyle(fontWeight: FontWeight.normal),
              decoration: inputDecoration,
            );
          },
          displayStringForOption: widget.displayStringForOption,
          optionsBuilder: (TextEditingValue v) {
            return widget.delegate(v.text);
          },
          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
            final theme = Theme.of(context);

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 600),
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
                            final highlightedIndex = AutocompleteHighlightedOption.of(context);
                            final highlight = highlightedIndex == index;
                            if (highlight) {
                              SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                                Scrollable.ensureVisible(context, alignment: 0.5);
                              });
                            }

                            return Container(
                              // theme.primaryColorDark : theme.primaryColorLight,
                              color: highlight ? Theme.of(context).focusColor : null,
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
      _controller.text = widget.displayStringForOption(widget.initialValue);
      final style = widget.deleted ? const TextStyle(color: Colors.grey) : const TextStyle(fontWeight: FontWeight.bold);

      return TextField(
        readOnly: true,
        controller: _controller,
//        focusNode: fieldFocusNode,
        style: style,
        decoration: inputDecoration,
      );
    }
  }
}
