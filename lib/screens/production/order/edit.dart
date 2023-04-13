import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_date_field.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_edit.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class ProductionOrderEdit extends EntityHolder {
  const ProductionOrderEdit({super.key, required super.entity});

  @override
  State<ProductionOrderEdit> createState() => _ProductionOrderEditState();
}

class _ProductionOrderEditState extends State<ProductionOrderEdit> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_productionOrderEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _onSave(BuildContext context) {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      print("state ${state.value}");
      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data['_id'] = widget.entity.json['_id'];

      // workaround
      data['date'] = DateFormat("yyyy-MM-dd").format(data["date"]);

      context.read<MemoryBloc>().add(MemorySave(
          "memories", ProductionOrder.ctx, ProductionOrder.schema, MemoryItem(id: widget.entity.id, json: data)));
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
      context.read<UiBloc>().add(ChangeView(ProductionOrder.ctx));
      // TODO context.read<UiBloc>().add(PreviousRoute());
    }

    return EditScaffold(
      entity: widget.entity,
      title: widget.entity.isNew
          ? localization.translate("new production order")
          : localization.translate("edit production order"),
      onClose: routerBack,
      onCancel: routerBack,
      onSave: _onSave,
      afterSave: (context, entity) => context.read<UiBloc>().add(ChangeView(ProductionOrder.ctx, entity: entity)),
      body: AppForm(
        schema: ProductionOrder.schema,
        formKey: _formKey,
        focusNode: _focusNode,
        entity: getEntity(),
        child: ScrollableListView(children: <Widget>[
          FormCard(isLast: true, children: <Widget>[
            DateField(
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
              creatable: false,
              ctx: const ['production', 'area'],
              name: 'area',
              label: localization.translate('area'),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              // keyboardType: TextInputType.text,
            ),
            DecoratedFormPickerField(
              creatable: false,
              ctx: const ['person'],
              name: 'operator',
              label: localization.translate("operator"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: (context) {},
            ),
            DecoratedFormPickerField(
              creatable: false,
              ctx: const ['product'],
              name: 'product',
              label: localization.translate("product"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              // keyboardType: TextInputType.text,
            ),
            DecoratedFormField(
              name: 'material',
              label: localization.translate("material"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: (context) {},
              keyboardType: TextInputType.text,
            ),
            DecoratedFormField(
              name: 'thickness',
              label: localization.translate("thickness"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: (context) {},
              keyboardType: TextInputType.text,
            ),
            DecoratedFormField(
              name: 'planned',
              label: localization.translate("planned qty"),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              keyboardType: TextInputType.number,
            ),
          ])
        ]),
      ),
    );
  }

  MemoryItem getEntity() {
    if (widget.entity.isNew && widget.entity.json["date"] == null) {
      final json = Map.of(widget.entity.json);
      json["date"] = DateTime.now(); // Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    } else {
      final json = Map.of(widget.entity.json);
      json["date"] = DateTime.parse(json["date"]); //DateFormat("yyyy-MM-dd").format(json["date"]);
      return MemoryItem(id: widget.entity.id, json: json);
    }
    return widget.entity;
  }
}
