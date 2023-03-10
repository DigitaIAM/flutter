import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_header.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_divider.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

class ProductionOrderView extends EntityHolder {
  final int tabIndex;

  const ProductionOrderView({super.key, required super.entity, required this.tabIndex});

  @override
  State<ProductionOrderView> createState() => _ProductionOrderViewState();
}

class _ProductionOrderViewState extends State<ProductionOrderView> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
        vsync: this, length: 2, initialIndex: 0 // widget.isFilter ? 0 : state.productionOrderUIState.tabIndex
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
          Tab(text: localization.translate("production")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(controller: _controller, children: <Widget>[
              ProductionOrderOverview(order: widget.entity),
              (widget.entity.json["date"] == Utils.today())
                  ? ProductionOrderProduced(order: widget.entity)
                  : ProductionOrderProducedView(order: widget.entity),
            ]),
          ),
        ]);
      }),
    );
  }
}

class ProductionOrderOverview extends StatelessWidget {
  final MemoryItem order;

  const ProductionOrderOverview({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final widgets = <Widget>[
      EntityHeader(pairs: [
        // Pair(localization.translate("production order"), memoryItem.json['date'])
        Pair(localization.translate("plan"), order.json['planned'] ?? '-'),
        Pair(localization.translate("produced"), order.json['produced']?['piece'] ?? '-'),
        Pair(localization.translate("boxes"), order.json['produced']?['box'] ?? '-'),
      ]),
      ListDivider(),
      ListTile(
        title: Text(order.json['product'].name()),
        subtitle: Text(localization.translate("product")),
      ),
      ListTile(
        title: Text(order.json['area'].name()),
        subtitle: Text(localization.translate("area")),
      ),
      ListTile(
        title: Text(order.json['date']),
        subtitle: Text(localization.translate("date")),
      ),
      ListDivider(),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }
}

class ProductionOrderProduced extends StatefulWidget {
  final MemoryItem order;

  const ProductionOrderProduced({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _ProductionOrderProducedState();
}

class _ProductionOrderProducedState extends State<ProductionOrderProduced> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_productionOrderProducedEdit');
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
              DecoratedFormPickerField(
                keepAsID: false,
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
              DecoratedFormField(
                name: 'label',
                label: localization.translate("label"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
                keyboardType: TextInputType.text,
              ),
              DecoratedFormPickerField(
                keepAsID: false,
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
                keepAsID: false,
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
                label: localization.translate("qty in box"),
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
        const Field("product", ReferenceType(['product']))
      ]);

      print("order ${order.json}");

      final orderId = order.id;
      final product = order.json['product'].json;
      final productName = product['name'] ?? '';
      final partNumber = product['part_number'] ?? '';

      final date = data['date'] ?? '';
      final customer = data['customer'] ?? '';
      final label = data['label'] ?? '';

      final operator = data['operator'];
      final operatorId = operator['_id'] ?? '';
      final operatorName = operator['name'] ?? '';

      final control = data['control'];
      final controlId = control['_id'] ?? '';
      final controlName = control['name'] ?? '';

      final qty = data['qty'] ?? 0;

      final result = await Labels.connect(ip, port, (printer) async {
        setState(() => status = "registering");
        final record = await Api.feathers().create(serviceName: 'memories', data: {
          'order': orderId,
          'date': date,
          'operator': operatorId,
          'control': controlId,
          'qty': qty
        }, params: {
          'oid': Api.instance.oid,
          'ctx': ['production', 'produce']
        });

        setState(() => status = "printing");

        final id = record['_id'];

        final dd = DateFormat.yMMMMd().format(DateTime.parse(date));

        final Map<String, String> labelData = {
          "??????????????????": productName,
          "??????????????": partNumber,
          "????????": dd,
          "????????????????????": "$qty ????",
          "line1": "",
          "????????????????": operatorName,
          "????????????????": controlName,
          "line2": "",
          "????????????????": label,
          "????????????????": customer,
        };

        Labels.lines(printer, id, labelData);

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

class ProductionOrderProducedView extends StatelessWidget {
  final MemoryItem order;

  const ProductionOrderProducedView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final ctx = ['production', 'produce'];
    final schema = [
      const Field('qty', NumberType()),
      Field('code', CalculatedType((MemoryItem bag) async {
        return bag.id.split('T').last;
      }))
    ];
    return BlocProvider(
      create: (context) => MemoryBloc()..add(MemoryFetch('memories', ctx, schema: schema, filter: {'order': order.id})),
      child: MemoryList(
        ctx: ctx,
        schema: schema,
        title: (MemoryItem item) => item.json['qty'],
        subtitle: (MemoryItem item) => item.id.split('T').last,
        onTap: (MemoryItem item) => {},
      ),
    );
  }
}
