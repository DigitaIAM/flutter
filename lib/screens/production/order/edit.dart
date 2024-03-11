import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
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
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_productionOrderEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  MemoryItem? product;

  @override
  void initState() {
    super.initState();

    final p = widget.entity.json[cProduct];
    if (p is MemoryItem) {
      product = p;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _onSave(BuildContext context) {
    // print("_onSave");
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      // print("state ${state.value}");
      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data[cId] = widget.entity.json[cId];

      // workaround
      data[cDate] = DateFormat("yyyy-MM-dd").format(data[cDate]);

      context.read<MemoryBloc>().add(MemorySave(
            "memories",
            ProductionOrder.ctx,
            ProductionOrder.schema,
            MemoryItem(
              id: widget.entity.id,
              json: data,
            ),
          ));
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

    // print("Widget build");

    return EditScaffold(
      entity: widget.entity,
      title: widget.entity.isNew
          ? localization.translate("new production order")
          : localization.translate("edit production order"),
      onClose: routerBack,
      onCancel: routerBack,
      onSave: _onSave,
      afterSave: (context, entity) => context
          .read<UiBloc>()
          .add(ChangeView(ProductionOrder.ctx, entity: entity)),
      body: AppForm(
        schema: ProductionOrder.schema,
        formKey: _formKey,
        focusNode: _focusNode,
        entity: getEntity(),
        child: ScrollableListView(children: <Widget>[
          FormCard(isLast: true, children: <Widget>[
            DateField(
              name: cDate,
              label: localization.translate(cDate),
              autofocus: false,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              keyboardType: TextInputType.datetime,
            ),
            DecoratedFormPickerField(
              creatable: false,
              ctx: const ['production', 'area'],
              name: cArea,
              label: localization.translate(cArea),
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
              name: cOperator,
              label: localization.translate(cOperator),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: (context) {},
            ),
            (product != null && (product!.json[cType] ?? '') != 'roll')
                ? DecoratedFormPickerField(
                    creatable: false,
                    ctx: const ['person'],
                    name: cPacker,
                    label: localization.translate(cPacker),
                    autofocus: true,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    onSave: (context) {},
                  )
                : Container(),
            DecoratedFormPickerField(
              creatable: false,
              ctx: const ['product'],
              name: cProduct,
              label: localization.translate(cProduct),
              autofocus: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
              onSave: _onSave,
              onChange: (item) {
                // print("onChange: (item) $item");
                setState(() {
                  product = item;
                });
              },
              // keyboardType: TextInputType.text,
            ),
            ...additional(context),
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
    if (widget.entity.isNew && widget.entity.json[cDate] == null) {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.now(); // Utils.today();
      return MemoryItem(id: widget.entity.id, json: json);
    } else {
      final json = Map.of(widget.entity.json);
      json[cDate] = DateTime.parse(
          json[cDate]); //DateFormat("yyyy-MM-dd").format(json[cDate]);
      return MemoryItem(id: widget.entity.id, json: json);
    }
  }

  List<Widget> additional(BuildContext context) {
    // print("additional");
    if (product != null && (product!.json[cType] ?? '') == 'roll') {
      final localization = AppLocalizations.of(context);
      return [
        DecoratedFormField(
          name: 'material',
          label: localization.translate("raw material"),
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
      ];
    }
    return [];
  }
}
