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
import 'package:nae/widgets/scrollable_list_view.dart';

class WHInventoryDocumentCreation extends StatefulWidget {
  final MemoryItem doc;

  const WHInventoryDocumentCreation({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHInventoryDocumentCreationState();
}

class _WHInventoryDocumentCreationState extends State<WHInventoryDocumentCreation> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHInventoryDocumentCreation');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {cDate: Utils.today()});

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

    if (data == null) {
      return;
    }

    final date = data[cDate] ?? '';
    final storage = data[cStorage] as MemoryItem;

    final record = await Api.feathers().create(serviceName: 'memories', data: {
      cDate: date,
      cStorage: storage.id,
    }, params: {
      'oid': Api.instance.oid,
      'ctx': ['warehouse', 'inventory', 'document']
    });

    context.read<UiBloc>().add(ChangeView(WHInventory.ctx, action: 'edit', entity: MemoryItem.from(record)));
  }
}
