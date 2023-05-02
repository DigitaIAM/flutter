import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/screens/wh/inventory/screen.dart';
import 'package:nae/screens/wh/list_builder.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_field.dart';

class WHInventoryShowStock extends StatefulWidget {
  final MemoryItem doc;

  const WHInventoryShowStock({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHInventoryShowStockState();
}

class _WHInventoryShowStockState extends State<WHInventoryShowStock> {
  final GlobalKey<FormBuilderState> _formKey =
      GlobalKey<FormBuilderState>(debugLabel: '_WHInventoryShowStockState');

  final FocusScopeNode _focusNode = FocusScopeNode();

  void _onSave(BuildContext context) {
    final state = _formKey.currentState;
    if (state != null && state.saveAndValidate()) {
      debugPrint('new data');
      debugPrint(_formKey.currentState?.value.toString());

      final Map<String, dynamic> data = Map.from(state.value);
      // workaround
      data['_id'] = widget.doc.id;

      context.read<MemoryBloc>().add(MemorySave("memories", WHInventory.ctx,
          WHInventory.schema, MemoryItem(id: widget.doc.id, json: data)));
    } else {
      debugPrint(_formKey.currentState?.value.toString());
      debugPrint('validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Pair> pairs = [];

    final storage = widget.doc.json['storage'] is MemoryItem
        ? widget.doc.json['storage']
        : MemoryItem(
            id: widget.doc.json['storage']['_id'],
            json: widget.doc.json['storage']);

    pairs.add(Pair('storage', storage));

    return ListBuilder(
        filters: List.from(pairs),
        down: (context, filters) => callBack(context, filters),
        ctx: const ['warehouse', 'stock'],
        schema: WHInventory.schema);
  }

  Future callBack(BuildContext context, List<Pair> filters) {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (ctx) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: enteringAmount(context, filters),
      ),
    );
  }

  Widget enteringAmount(BuildContext context, List<Pair> filters) {
    final localization = AppLocalizations.of(context);

    List<Widget> widgets = [];

    final MemoryItem details = MemoryItem(
        id: '', json: {'date': Utils.today()}); // TODO input doc date?

    widgets.add(const Text('Enter the amount of goods:'));

    widgets.add(DecoratedFormField(
      name: 'qty',
      label: localization.translate("qty"),
      autofocus: true,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
      onSave: (context) => _onSave,
      keyboardType: TextInputType.number,
    ));

    widgets.add(Container(height: 10));

    widgets.add(
      ElevatedButton(
        onPressed: () => registerDocument(context, filters),
        // onPressed: () => {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(localization.translate('register')),
      ),
    );

    return AppForm(
        entity: details,
        formKey: _formKey,
        focusNode: _focusNode,
        onChanged: () {
          _formKey.currentState!.save();
          debugPrint("onChanged: ${_formKey.currentState!.value}");
        },
        child: Column(children: widgets));
  }

  void registerDocument(BuildContext context, List<Pair> filters) {
    final data = _formKey.currentState?.value;
    if (data == null) {
      return;
    }

    MemoryItem? goods;
    for (final filter in filters) {
      if (filter.label == 'goods') {
        goods = filter.value;
        break;
      }
    }

    if (goods == null) {
      return;
    }

    // print("data type ${data.runtimeType}");
    print("inventory_data $data");
    print("inventory_doc ${widget.doc.json}");

    final qty = data['qty'];

    context.read<MemoryBloc>().add(MemoryCreate("memories", const [
          'warehouse',
          'inventory'
        ], const [], {
          "document": widget.doc.id,
          "goods": goods.id,
          'qty': {'number': qty}
        }));
  }
}
