import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';

import '../../../api.dart';
import '../../../printer/labels.dart';
import '../../../printer/network_printer.dart';
import '../../../share/utils.dart';
import '../../../widgets/app_form.dart';
import '../../../widgets/app_form_card.dart';
import '../../../widgets/app_form_field.dart';
import '../../../widgets/app_form_picker_field.dart';
import '../../../widgets/scrollable_list_view.dart';
import 'screen.dart';

class WHBalanceView extends EntityHolder {
  final int tabIndex;

  const WHBalanceView(
      {super.key, required super.entity, required this.tabIndex});

  @override
  State<WHBalanceView> createState() => _WHBalanceViewState();
}

class _WHBalanceViewState extends State<WHBalanceView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
      vsync: this, length: 2,
      initialIndex: 0, // widget.isFilter ? 0 : state.WHDispatchUIState.tabIndex
    );
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // if (widget.isFilter) {
    //   return;
    // }

    // final store = StoreProvider.of<AppState>(context);
    // store.dispatch(UpdateProductTab(tabIndex: _controller.index));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tabIndex != widget.tabIndex) {
      _controller.index = widget.tabIndex;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return ScaffoldView(
      appBarBottom: TabBar(
        controller: _controller,
        isScrollable: true,
        tabs: [
          Tab(text: localization.translate("overview")),
          Tab(text: localization.translate("print")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(controller: _controller, children: <Widget>[
              WHTransactionsBuilder(widget.entity),
              WHBalanceProduced(order: widget.entity)
            ] //WHDispatchOverview(doc: widget.entity), WHDispatchGoods(doc: widget.entity)]),
                ),
          ),
        ]);
      }),
    );
  }
}

class WHTransactionsBuilder extends StatelessWidget {
  final MemoryItem entity;

  const WHTransactionsBuilder(this.entity, {super.key});

  @override
  Widget build(BuildContext context) {
    final schema = [
      Field('description', CalculatedType((MemoryItem rec) async {
        final t = rec.json['type'];
        if (t == 'open_balance' || t == 'close_balance') {
          return 'balance at ${rec.json['date']}';
        } else {
          final response = await Api.feathers()
              .get(serviceName: "memories", objectId: rec.id, params: {"oid": Api.instance.oid, "ctx": []}).onError((error, stackTrace) => {});

          final Map map = response == {} ? response : Map.from(response);

          final id = map['document'] ?? "";

          final split = id.toString().split('/');

          final ctx = split.length >= 3 ? split.sublist(0, 3) : [];

          final document = await Api.feathers()
              .get(serviceName: "memories", objectId: id, params: {"oid": Api.instance.oid, "ctx": ctx}).onError((error, stackTrace) => {});

          final Map map_doc = document == {} ? document : Map.from(document);

          final date = map_doc['date'] ?? "?";

          return date.toString();
        }
      })),
      Field(
          'receive',
          CalculatedType((MemoryItem rec) async {
            switch (rec.json['type']) {
              case 'receive':
              case 'open_balance':
              case 'close_balance':
                return rec.json['qty'];
              default:
                return '';
            }
          })),
      Field(
          'issue',
          CalculatedType((MemoryItem rec) async =>
              rec.json['type'] == 'issue' ? rec.json['qty'] : '')),
    ];

//    let goods = this.entity.

//    print("entity ${this.entity.toJson()}");

    final filter = {
      'dates': {'from': '2022-12-01', 'till': '2023-12-30'},
      'storage': this.entity.toJson()['storage'].toString(),
      'goods': this.entity.toJson()['goods'].toString(),
      'batch_id': this.entity.toJson()['batch']['id'].toString(),
      'batch_date': this.entity.toJson()['batch']['date'].toString(),
    };

    print("FILTER: ${filter}");

    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => MemoryBlocHolder(
        init: (bloc) => bloc.add(
            MemoryFetch('inventory', const [], schema: schema, filter: filter)),
        child: screen(context, uiState, schema, filter),
      ),
    );
  }

  Widget screen(BuildContext context, UiState uiState, List<Field> schema,
      Map<String, dynamic> filter) {
    return MemoryList(
      service: 'inventory',
      ctx: const [],
      schema: schema,
      filter: filter,
      title: (MemoryItem item) => item.name(),
      subtitle: (MemoryItem item) =>
          '${fQty.resolve(item.json)} ${fUom.resolve(item.json)}',
      onTap: (MemoryItem item) =>
          context.read<UiBloc>().add(ChangeView(WHBalance.ctx, entity: item)),
    );
  }
}


class WHBalanceProduced extends StatefulWidget {
  final MemoryItem order;

  const WHBalanceProduced({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _WHBalanceProducedState();
}

class _WHBalanceProducedState extends State<WHBalanceProduced> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_WHBalanceProducedEdit');
  final FocusScopeNode _focusNode = FocusScopeNode();

  final MemoryItem details = MemoryItem(id: '', json: {'date': Utils.today()});

  String status = "register";

  @override
  Widget build(BuildContext context) {
    print("CONTEXT: ${context}");
//    final x =
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
              DecoratedFormPickerField(
                ctx: const ['printer'],
                name: 'printer',
                label: localization.translate("printer"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormField(
                name: 'date',
                label: localization.translate("date"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.datetime,
                readOnly: true,
              ),
              DecoratedFormField(
                name: 'customer',
                label: localization.translate("customer"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.text,
              ),
              DecoratedFormPickerField(
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
                ctx: const ['person'],
                name: 'control',
                label: localization.translate("control"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormField(
                name: 'qty',
                label: localization.translate("qty"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: status == 'register' ? registerAndPrint : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate(status)),
              )
            ])
          ]))
    ];
    return ScrollableListView(
      children: widgets,
    );
  }

  void registerAndPrint() async {
    setState(() => status = "connecting");
    try {
      print("pressed:");

      final data = _formKey.currentState?.value;
      if (data == null) {
        return;
      }

      final ip = data['printer']['ip'];
      final port = int.parse(data['printer']['port']);

      print("printer $ip $port");

      final order = await widget.order.enrich([
        fProduct,
      ]);

      print("order ${order.json}");

      final orderId = order.id;
      final product = order.json['product'].json;
      final productName = product['name'] ?? '';
      final partNumber = product['part_number'] ?? '';

      final date = data['date'] ?? '';
      final customer = data['customer'] ?? '';

      final operator = data['operator'];
      final operatorId = operator['_id'] ?? '';
      final operatorName = operator['name'] ?? '';

      final control = data['control'];
      final controlId = control['_id'] ?? '';
      final controlName = control['name'] ?? '';

      final qty = data['qty'] ?? 0;

      final uom = order.json['uom'].json;

      final barcode = order.json['barcode'].json;

      final result = await Labels.connect(ip, port, (printer) async {
        setState(() => status = "registering");
        final record = await Api.feathers().create(serviceName: 'memories', data: {
          'order': orderId,
          'date': date,
          'operator': operatorId,
          'control': controlId,
          'qty': qty,
          'barcode': barcode,
        }, params: {
          'oid': Api.instance.oid,
          'ctx': ['production', 'produce']
        });

        setState(() => status = "printing");

        final id = record['_id'];

        final dd = DateFormat.yMMMMd().format(DateTime.parse(date));

        final Map<String, String> labelData = {
          "продукция": productName,
          "артикул": partNumber,
          "дата": dd,
          "количество": "$qty $uom",
          "line1": "",
          "оператор": operatorName,
          "проверил": controlName,
          "line2": "",
          "заказчик": customer,
        };

        Labels.lines_with_barcode(printer, id, barcode, labelData);

        return Future<PrintResult>.value(PrintResult.success);
      });

      if (result != PrintResult.success) {
        showToast(result.msg,
            // context: context,
            axis: Axis.horizontal,
            alignment: Alignment.center,
            position: StyledToastPosition.bottom);
      }
    } catch (e, stacktrace) {
      print(stacktrace);
      showToast(e.toString(),
          // context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
    } finally {
      setState(() {
        status = "register";
      });
    }
  }
}