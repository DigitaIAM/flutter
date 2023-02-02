import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/model/memory/memory_bloc.dart';
import 'package:nae_hr/model/memory/memory_event.dart';
import 'package:nae_hr/model/ui/ui_bloc.dart';
import 'package:nae_hr/model/ui/ui_event.dart';
import 'package:nae_hr/screens/common/uom/screen.dart';
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
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_uomEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  void _onSave(BuildContext context) {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data['_id'] = widget.entity.json['_id'];

      debugPrint("saving");
      debugPrint(data.toString());

      print("sending event");
      context.read<MemoryBloc>().add(
          MemorySave("memories",
              UomScreen.route,
              MemoryItem(id: widget.entity.id, json: data)
          )
      );
      print("event send");
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }

    // if (_formKey.currentState?.validate() ?? false) {
    //   context.read<MemoryBloc>().add(MemorySave("memories", UomScreen.route, widget.entity));
    // }
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return EditScaffold(
      entity: widget.entity,
      title: widget.entity.isNew ? localization.translate("new uom") : localization.translate("edit uom"),
      onClose: (context) {
        context.read<UiBloc>().add(ChangeView(UomScreen.route)); // reset?
      },
      onCancel: (context) {
        context.read<UiBloc>().add(ChangeView(UomScreen.route)); // reset?
        // TODO context.read<UiBloc>().add(PreviousRoute());
      },
      onSave: _onSave,
      body: AppForm(
        formKey: _formKey,
        focusNode: _focusNode,
        entity: widget.entity,
        child: ScrollableListView(
          children: <Widget>[
            FormCard(
              isLast: true,
              children: <Widget>[
                DecoratedFormField(
                  name: 'label',
                  label: localization.translate("name"),
                  autofocus: true,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                      // (val) => val == null || val.isEmpty || val.trim().isEmpty
                      // ? localization.translate("please, enter name")
                      // : null,
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