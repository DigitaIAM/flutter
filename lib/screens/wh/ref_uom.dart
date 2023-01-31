import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/model/memory/memory_bloc.dart';
import 'package:nae_hr/model/memory/memory_event.dart';
import 'package:nae_hr/printer/labels.dart';
import 'package:nae_hr/printer/network_printer.dart';
import 'package:nae_hr/screens/wh/ref_uom_list.dart';
import 'package:nae_hr/widgets/master_detail_container.dart';
import 'package:provider/provider.dart';

import '../../api.dart';
import '../../widgets/item_details.dart';

class RefUom extends StatefulWidget {
  const RefUom({Key? key}) : super(key: key);

  @override
  State<RefUom> createState() => _RefUomState();
}

class _RefUomState extends State<RefUom> {

  final ctx = ["uom"];
  MemoryItem? selectedItem;
  late MemoryBloc bloc;


  @override
  void initState() {
    super.initState();
    bloc = MemoryBloc();
  }

  @override
  void dispose(){
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailContainer(
      title: 'Unit of measure',
      masterBuilder: MasterBuilder(builder: master),
      detailsBuilder: DetailsBuilder(builder: details, selected: selectedItem)
    );
  }

  Widget master(BuildContext context) {
    final settings = Provider.of<MySettings>(context);
    return BlocProvider(
      create: (_) => bloc..add(MemoryFetch("memories", ctx)),
      // child: UomList(),
      child: Column(
          children: [
            Row(
              children: [
                OutlinedButton(
                  child: Text(AppLocalizations.of(context).translate("create")),
                  onPressed: () {
                    setState(() {
                      selectedItem = const MemoryItem(id: "", json: {});
                    });
                  },
                ),
                OutlinedButton(
                  child: Text(AppLocalizations.of(context).translate("print")),
                  onPressed: () {
                    final labels = Labels();
                    labels.testPrint(context);
                  },
                ),
                OutlinedButton(
                  child: Text(AppLocalizations.of(context).translate("scan")),
                  onPressed: () {
                    scan();
                  },
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200.0,
                    child:
                      UomList(onSelected: (item) {
                        setState(() {
                          selectedItem = item;
                        });
                      })
                  )
                )
              ],
            )
          ]
      )
    );
  }

  List<Widget> details(BuildContext context, MemoryItem item) {
    final settings = Provider.of<MySettings>(context);

    final _formKey = GlobalKey<FormBuilderState>();

    return <Widget>[
      // OutlinedButton(
      //     child: Text(AppLocalizations.of(context).translate("save")),
      //     onPressed: () {
      //       print("saving");
      //     }
      // ),
      FormBuilder(
          key: _formKey,
          onChanged: () {
            _formKey.currentState!.save();
            debugPrint("onChanged: "+_formKey.currentState!.value.toString());
          },
          initialValue: item.json,
          autovalidateMode: AutovalidateMode.disabled,
          skipDisabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FormBuilderTextField(
                name: 'label',
                // decoration: InputDecoration(labelText: AppLocalizations.of(context).translate("label")),
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context).translate("label")),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // suffixIcon: const Icon(Icons.email),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final state = _formKey.currentState;
                        if (state != null && state.saveAndValidate()) {
                          final data = state.value;
                          debugPrint("onPressed");
                          debugPrint(data.toString());
                          if (item.id == "") {
                            bloc.add(MemoryCreate("memories", ctx, data));
                          } else {
                            bloc.add(MemoryUpdate("memories", ctx, data));
                          }
                        } else {
                          debugPrint(_formKey.currentState?.value.toString());
                          debugPrint('validation failed');
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                      },
                      // color: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          )
      ),
    ];
  }

  void scan() {
  }
}
