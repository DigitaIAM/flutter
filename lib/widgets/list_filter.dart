
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/utils/debouncer.dart';
import 'package:nae_hr/widgets/search_text.dart';

class ListFilter extends StatefulWidget {
  const ListFilter({super.key,
    required this.filter,
    required this.onFilterChanged
  });

  final String? filter;
  final Function(String?) onFilterChanged;

  @override
  State<StatefulWidget> createState() => _ListFilterState();
}

class _ListFilterState extends State<ListFilter> {

  final _debouncer = Debouncer();
  late TextEditingController _filterController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
    _focusNode = FocusNode()..addListener(onFocusChanged);
  }

  void onFocusChanged() {
    // workaround: prevent the TextField from refocusing on tab out
    if (_focusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    _focusNode.removeListener(onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterController.text = widget.filter ?? "";

    if (widget.filter != null) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SearchText(
              placeholder: AppLocalizations.of(context).translate('search'),
              filterController: _filterController,
              focusNode: _focusNode,
              onCleared: () => widget.onFilterChanged(null),
              onChanged: (value) {
                _debouncer.run(() {
                  widget.onFilterChanged(value);
                });
              },
              // placeholder: _getPlaceholder,
            ),
          ),
        ),
      ]
    );
  }
}