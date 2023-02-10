import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae_hr/api.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/printer/labels.dart';
import 'package:nae_hr/printer/network_printer.dart';
import 'package:nae_hr/schema/schema.dart';
import 'package:nae_hr/share/utils.dart';
import 'package:nae_hr/widgets/app_form.dart';
import 'package:nae_hr/widgets/app_form_card.dart';
import 'package:nae_hr/widgets/app_form_field.dart';
import 'package:nae_hr/widgets/app_form_picker_field.dart';
import 'package:nae_hr/widgets/entity_header.dart';
import 'package:nae_hr/widgets/entity_screens.dart';
import 'package:nae_hr/widgets/list_divider.dart';
import 'package:nae_hr/widgets/scaffold_view.dart';
import 'package:nae_hr/widgets/scrollable_list_view.dart';

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
              ProductionOrderProduced(order: widget.entity),
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
        Pair(localization.translate("planned"), order.json['planned'] ?? '0'),
        Pair(localization.translate("produced"), order.json['produced'] ?? '0'),
      ]),
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
      final operator = data['operator']['name'] ?? '';
      final control = data['control']['name'] ?? '';
      final qty = data['qty'] ?? 0;

      final result = await Labels.connect(ip, port, (printer) async {
        setState(() => status = "registering");
        final record = await Api.feathers().create(serviceName: 'memories', data: {
          'order': orderId,
          'date': date,
          'operator': operator,
          'control': control,
          'qty': qty
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
          "количество": "$qty шт",
          "line1": "",
          "оператор": operator, // "Кулмурадов",
          "проверил": control, // "Орипов",
          "line2": "",
          "этикетка": label,
          "заказчик": customer,
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
    } catch (e) {
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
