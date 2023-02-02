import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/model/ui/ui_bloc.dart';
import 'package:nae_hr/model/ui/ui_event.dart';
import 'package:nae_hr/screens/common/uom/uom_screen.dart';
import 'package:nae_hr/widgets/app_form.dart';
import 'package:nae_hr/widgets/app_form_card.dart';
import 'package:nae_hr/widgets/app_form_field.dart';
import 'package:nae_hr/widgets/entity_header.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_divider.dart';
import 'package:nae_hr/widgets/scaffold_edit.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

class UomEdit extends EntityHolder {
  const UomEdit({super.key, required super.entity});

  @override
  State<UomEdit> createState() => _UomEditState();

}

class _UomEditState extends State<UomEdit> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>(debugLabel: '_uomEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final _labelController = TextEditingController();

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO widget.viewModel.onSave(context);
      print("TODO SAVE");
    }
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return EditScaffold(
      entity: widget.entity,
      title: widget.entity.isNew ? localization.translate("new uom") : localization.translate("edit uom"),
      onCancel: (context) {
        context.read<UiBloc>().add(ChangeView(UomScreen.route)); // reset?
        // TODO context.read<UiBloc>().add(PreviousRoute());
      },
      onSave: _onSave,
      body: AppForm(
        formKey: _formKey,
        focusNode: _focusNode,
        child: ScrollableListView(
          key: ValueKey('__uom_${widget.entity.id}_${widget.entity.updatedAt}__'),
          children: <Widget>[
            FormCard(
              isLast: true,
              children: <Widget>[
                DecoratedFormField(
                  autofocus: true,
                  label: localization.translate("name"),
                  controller: _labelController,
                  validator: (val) => val == null || val.isEmpty || val.trim().isEmpty
                      ? localization.translate("please, enter name")
                      : null,
                  onSave: _onSave,
                  keyboardType: TextInputType.text,
                ),
              ]
            )
          ]
        )
      )
    );
  }
}

class UomOverview extends StatelessWidget {

  final MemoryItem entity;

  const UomOverview({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {

    final widgets = <Widget>[
      EntityHeader(
        label: AppLocalizations.of(context).translate("uom"),
        value: entity.label(),
      ),
      ListDivider(),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }
}