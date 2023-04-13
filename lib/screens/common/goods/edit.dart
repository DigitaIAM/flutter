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
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class GoodsEdit extends EntityHolder {
  const GoodsEdit({super.key, required super.entity});

  @override
  State<GoodsEdit> createState() => _GoodsEditState();
}

class _GoodsEditState extends State<GoodsEdit> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_goodsEdit');
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
          .add(MemorySave("memories", Goods.ctx, Goods.schema, MemoryItem(id: widget.entity.id, json: data)));
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
      title: widget.entity.isNew ? localization.translate("new goods") : localization.translate("edit goods"),
      onClose: (context) {
        context.read<UiBloc>().add(ChangeView(Goods.ctx));
      },
      onCancel: (context) {
        context.read<UiBloc>().add(ChangeView(Goods.ctx));
        // TODO context.read<UiBloc>().add(PreviousRoute());
      },
      onSave: _onSave,
      body: AppForm(
        schema: Goods.schema,
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
              onSave: _onSave,
              keyboardType: TextInputType.text,
            ),
            DecoratedFormPickerField(
              ctx: const ['uom'],
              name: 'uom',
              label: localization.translate("uom"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
            ),
          ])
        ]),
      ),
    );
  }
}
