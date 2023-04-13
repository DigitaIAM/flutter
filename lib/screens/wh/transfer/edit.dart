import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class WHTransferEdit extends EntityHolder {
  const WHTransferEdit({super.key, required super.entity});

  @override
  State<WHTransferEdit> createState() => _WHTransferEditState();
}

class _WHTransferEditState extends State<WHTransferEdit> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHTransferEdit');
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
      data['_id'] = widget.entity.json['_id'];

      context
          .read<MemoryBloc>()
          .add(MemorySave("memories", WHTransfer.ctx, WHTransfer.schema, MemoryItem(id: widget.entity.id, json: data)));
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
      context.read<UiBloc>().add(ChangeView(WHTransfer.ctx));
      // TODO context.read<UiBloc>().add(PreviousRoute());
    }

    return EditScaffold(
      entity: widget.entity,
      title: widget.entity.isNew
          ? localization.translate("new warehouse transfer")
          : localization.translate("edit warehouse transfer"),
      onClose: routerBack,
      onCancel: routerBack,
      onSave: _onSave,
      body: AppForm(
        schema: WHTransfer.schema,
        formKey: _formKey,
        focusNode: _focusNode,
        entity: getEntity(),
        child: ScrollableListView(children: <Widget>[
          FormCard(isLast: true, children: <Widget>[
            DecoratedFormField(
              name: 'date',
              label: localization.translate("date"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              keyboardType: TextInputType.datetime,
            ),
            DecoratedFormPickerField(
              ctx: const ['warehouse', 'storage'],
              name: 'from',
              label: localization.translate("from"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              // keyboardType: TextInputType.text,
            ),
            DecoratedFormPickerField(
              ctx: const ['warehouse', 'storage'],
              name: 'into',
              label: localization.translate('into'),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              // keyboardType: TextInputType.text,
            ),
          ])
        ]),
      ),
    );
  }

  MemoryItem getEntity() {
    if (widget.entity.isNew && widget.entity.json["date"] == null) {
      final json = Map.of(widget.entity.json);
      json["date"] = Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    }
    return widget.entity;
  }
}
