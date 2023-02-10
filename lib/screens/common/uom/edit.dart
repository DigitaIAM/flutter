import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/models/memory/bloc.dart';
import 'package:nae_hr/models/memory/event.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/models/memory/state.dart';
import 'package:nae_hr/models/ui/bloc.dart';
import 'package:nae_hr/models/ui/event.dart';
import 'package:nae_hr/widgets/app_form.dart';
import 'package:nae_hr/widgets/app_form_card.dart';
import 'package:nae_hr/widgets/app_form_field.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/scaffold_edit.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

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
      data['_id'] = widget.entity.json['_id'];

      debugPrint("saving");
      debugPrint(data.toString());

      print("sending event");
      context.read<MemoryBloc>().add(MemorySave("memories", Uom.ctx, MemoryItem(id: widget.entity.id, json: data)));
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

    routerBack(BuildContext context) {
      context.read<UiBloc>().add(ChangeView(Uom.ctx));
      // TODO context.read<UiBloc>().add(PreviousRoute());
    }

    return BlocListener<MemoryBloc, RequestState>(
        listener: (context, state) {
          if (state.saveStatus == SaveStatus.success) {
            routerBack(context);
          } else if (state.saveStatus == SaveStatus.failure) {}
        },
        child: EditScaffold(
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
                      name: 'name',
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
                  ])
                ]))));
  }
}
