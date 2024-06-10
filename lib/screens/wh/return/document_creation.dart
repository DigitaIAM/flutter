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
import 'package:nae/screens/wh/return/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHReturnDocumentCreation extends EntityHolder {
  const WHReturnDocumentCreation({super.key, required super.entity});

  @override
  State<StatefulWidget> createState() => _WHReturnDocumentCreationState();
}

class _WHReturnDocumentCreationState extends State<WHReturnDocumentCreation> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHReturnDocumentCreation');
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
              DecoratedFormPickerField(
                ctx: const ['counterparty'],
                name: cCounterparty,
                creatable: false,
                label: localization.translate(cCounterparty),
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
      title: localization.translate("return to the warehouse"),
      body: Builder(
        builder: (context) {
          return Column(children: widgets);
        },
      ),
    );
  }

  Future<dynamic> registerDocument(BuildContext context) async {
    final data = _formKey.currentState?.value;

    // print("data type ${data.runtimeType}");

    if (data == null) {
      return;
    }

    // print("data $data");

    final date = data[cDate] ?? '';
    final storage = data[cStorage] as MemoryItem;
    final counterparty = data[cCounterparty] as MemoryItem;

    var record;
    if (widget.entity.isNew) {
      record = await Api.feathers().create(serviceName: 'memories', data: {
        cDate: date,
        cStorage: storage.id,
        cCounterparty: counterparty.id,
      }, params: {
        'oid': Api.instance.oid,
        'ctx': WHReturn.ctx
      });
    } else {
      record = await Api.feathers()
          .update(serviceName: 'memories', objectId: widget.entity.id, data: {
        cDate: date,
        cStorage: storage.id,
        cCounterparty: counterparty.id,
      }, params: {
        'oid': Api.instance.oid,
        'ctx': WHReturn.ctx
      });
    }

    if (mounted) {
      final entity = MemoryItem.from(record);
      await entity.enrich(WHReturn.schema);

      // print("record: $record");

      context
          .read<UiBloc>()
          .add(ChangeView(WHReturn.ctx, action: 'view', entity: entity));
    }
  }
}
