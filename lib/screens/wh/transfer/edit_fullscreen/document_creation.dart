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
import 'package:nae/screens/wh/transfer/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHTransferDocumentCreation extends EntityHolder {
  const WHTransferDocumentCreation({super.key, required super.entity});

  @override
  State<StatefulWidget> createState() => _WHTransferDocumentCreationState();
}

class _WHTransferDocumentCreationState
    extends State<WHTransferDocumentCreation> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHTransferDocumentCreation');
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
                name: cFrom,
                creatable: false,
                label: localization.translate(cFrom),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'storage'],
                name: cInto,
                creatable: false,
                label: localization.translate(cInto),
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
      title: localization.translate("warehouse transfer"),
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
    final from = data[cFrom] as MemoryItem;
    final into = data[cInto] as MemoryItem;

    final record = await Api.feathers().create(serviceName: 'memories', data: {
      cDate: date,
      cFrom: from.id,
      cInto: into.id,
    }, params: {
      'oid': Api.instance.oid,
      'ctx': ['warehouse', 'transfer', 'document']
    });

    // print("record: $record");

    if (mounted) {
      final entity = MemoryItem.from(record);
      await entity.enrich(WHTransfer.schema);

      // print("show entity");

      context
          .read<UiBloc>()
          .add(ChangeView(WHTransfer.ctx, action: 'view', entity: entity));
    }
  }
}
