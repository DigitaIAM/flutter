import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/screens/wh/receive/screen.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class WHReceiveDocumentCreation extends StatefulWidget {
  final MemoryItem doc;

  const WHReceiveDocumentCreation({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHReceiveDocumentCreationState();
}

class _WHReceiveDocumentCreationState extends State<WHReceiveDocumentCreation> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHReceiveDocumentCreation');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  String status = "register";

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
                name: 'date',
                label: localization.translate("date"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.datetime,
              ),
              DecoratedFormPickerField(
                ctx: const ['counterparty'],
                name: 'counterparty',
                label: localization.translate("counterparty"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'storage'],
                name: 'storage',
                creatable: false,
                label: localization.translate('storage'),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              Container(height: 10),
              ElevatedButton(
                onPressed: status == 'register' ? () => registerDocument(context) : null,
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
    return ScrollableListView(
      children: widgets,
    );
  }

  Future<dynamic> registerDocument(BuildContext context) async {
    final data = _formKey.currentState?.value;

    // print("data type ${data.runtimeType}");

    if (data == null) {
      return;
    }

    // print("data $data");

    final date = data['date'] ?? '';
    final counterparty = data['counterparty'] as MemoryItem;
    final storage = data['storage'] as MemoryItem;

    final record = await Api.feathers().create(serviceName: 'memories', data: {
      'date': date,
      'counterparty': counterparty.id,
      'storage': storage.id,
    }, params: {
      'oid': Api.instance.oid,
      'ctx': ['warehouse', 'receive', 'document']
    });

    // print("record: $record");

    context.read<UiBloc>().add(ChangeView(WHReceive.ctx, action: 'edit', entity: MemoryItem.from(record)));
  }
}
