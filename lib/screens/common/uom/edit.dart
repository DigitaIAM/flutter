import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class UomEdit extends EntityHolder {
  const UomEdit({super.key, required super.entity});

  @override
  State<UomEdit> createState() => _UomEditState();
}

class _UomEditState extends State<UomEdit> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_uomEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _onSave(BuildContext context) {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data[cId] = widget.entity.json[cId];

      context
          .read<MemoryBloc>()
          .add(MemorySave("memories", Uom.ctx, Uom.schema, MemoryItem(id: widget.entity.id, json: data)));
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

    routerBack(BuildContext context) {
      context.read<UiBloc>().add(ChangeView(Uom.ctx));
      // TODO context.read<UiBloc>().add(PreviousRoute());
    }

    return EditScaffold(
      entity: widget.entity,
      title: widget.entity.isNew ? localization.translate("new uom") : localization.translate("edit uom"),
      onClose: (context) {
        context.read<UiBloc>().add(ChangeView(Uom.ctx));
      },
      onCancel: routerBack,
      onSave: _onSave,
      body: AppForm(
        formKey: _formKey,
        focusNode: _focusNode,
        entity: widget.entity,
        child: ScrollableListView(children: <Widget>[
          FormCard(isLast: true, children: <Widget>[
            DecoratedFormField(
              name: cName,
              label: localization.translate(cName),
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
          ])
        ]),
      ),
    );
  }
}
