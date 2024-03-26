import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/wh/inventory/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHInventoryDocumentEdit extends EntityHolder {
  const WHInventoryDocumentEdit({super.key, required super.entity});

  @override
  State<StatefulWidget> createState() => _WHInventoryDocumentEditState();
}

class _WHInventoryDocumentEditState extends State<WHInventoryDocumentEdit> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHInventoryDocumentEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  late MemoryItem details;

  String status = "register";

  @override
  void initState() {
    super.initState();

    if (widget.entity.isNew) {
      details = MemoryItem(id: '', json: {cDate: Utils.today()});
    } else {
      details = MemoryItem.from(widget.entity.json);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final widgets = <Widget>[
      AppForm(
          entity: details,
          formKey: _formKey,
          focusNode: _focusNode,
          onChanged: () {
            _formKey.currentState!.save();
            debugPrint("onChanged: ${_formKey.currentState!.value}");
          },
          child: ScrollableListView(children: <Widget>[
            FormCard(isLast: true, children: <Widget>[
              DecoratedFormField(
                name: cDate,
                label: localization.translate(cDate),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.datetime,
              ),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'storage'],
                name: cStorage,
                creatable: false,
                label: localization.translate(cStorage),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              Container(height: 10),
              ElevatedButton(
                onPressed: status == 'register'
                    ? () => registerDocument(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate(status)),
              ),
            ])
          ]))
    ];
    return ScaffoldView(
      title: localization.translate("warehouse inventory"),
      body: Builder(
        builder: (context) {
          return Column(children: widgets);
        },
      ),
    );
  }

  Future<dynamic> registerDocument(BuildContext context) async {
    final data = _formKey.currentState?.value;

    if (data == null) {
      return;
    }

    final date = data[cDate] ?? '';
    final storage = data[cStorage] as MemoryItem;

    var record;
    if (widget.entity.isNew) {
      record = await Api.feathers().create(
        serviceName: 'memories',
        data: {
          cDate: date,
          cStorage: storage.id,
        },
        params: {'oid': Api.instance.oid, 'ctx': WHInventory.ctx},
      );
    } else {
      record = await Api.feathers().update(
        serviceName: 'memories',
        objectId: widget.entity.id,
        data: {
          cDate: date,
          cStorage: storage.id,
        },
        params: {'oid': Api.instance.oid, 'ctx': WHInventory.ctx},
      );
    }

    context.read<UiBloc>().add(ChangeView(WHInventory.ctx,
        action: 'view', entity: MemoryItem.from(record)));
  }
}
