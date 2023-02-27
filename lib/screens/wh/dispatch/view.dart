import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:nae/api.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/printer/labels.dart';
import 'package:nae/printer/network_printer.dart';
import 'package:nae/share/utils.dart';
import 'package:nae/widgets/app_form.dart';
import 'package:nae/widgets/app_form_card.dart';
import 'package:nae/widgets/app_form_field.dart';
import 'package:nae/widgets/app_form_picker_field.dart';
import 'package:nae/widgets/entity_header.dart';
import 'package:nae/widgets/entity_screens.dart';
import 'package:nae/widgets/list_divider.dart';
import 'package:nae/widgets/scaffold_view.dart';
import 'package:nae/widgets/scrollable_list_view.dart';

import 'screen.dart';

class WHDispatchView extends EntityHolder {
  final int tabIndex;

  const WHDispatchView({super.key, required super.entity, required this.tabIndex});

  @override
  State<WHDispatchView> createState() => _WHDispatchViewState();
}

class _WHDispatchViewState extends State<WHDispatchView> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();

    // final state = widget.viewModel.state;
    _controller = TabController(
      vsync: this, length: 2, initialIndex: 0, // widget.isFilter ? 0 : state.whDispatchUIState.tabIndex
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
          Tab(text: localization.translate("goods")),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(children: <Widget>[
          Expanded(
            child: TabBarView(
                controller: _controller,
                children: <Widget>[WHDispatchOverview(doc: widget.entity), WHDispatchGoods(doc: widget.entity)]),
          ),
        ]);
      }),
    );
  }
}

class WHDispatchOverview extends StatelessWidget {
  final MemoryItem doc;

  const WHDispatchOverview({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final widgets = <Widget>[
      EntityHeader(pairs: [
        Pair(localization.translate("date"), doc.json['date'] ?? '-'),
      ]),
      ListDivider(),
    ];

    return ScrollableListView(
      children: widgets,
    );
  }
}

class WHDispatchGoods extends StatefulWidget {
  final MemoryItem doc;

  const WHDispatchGoods({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _WHDispatchGoodsState();
}

class _WHDispatchGoodsState extends State<WHDispatchGoods> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>(debugLabel: '_whDispatchGoodsEdit');
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
                ctx: const ['printer'],
                name: 'printer',
                label: localization.translate("printer"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormPickerField(
                ctx: const ['warehouse', 'storage'],
                name: 'storage',
                label: localization.translate("storage"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormPickerField(
                ctx: const ['goods'],
                name: 'goods',
                label: localization.translate("goods"),
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                onSave: (context) {},
              ),
              DecoratedFormPickerField(
                ctx: const ['uom'],
                name: 'uom',
                label: localization.translate("uom"),
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

      final doc = await widget.doc.enrich(WHDispatch.schema);

      print("doc ${doc.json}");

      final docId = doc.id;
      final goods = data['goods'] as MemoryItem;
      final uom = data['uom'] as MemoryItem;

      final date = doc.json['date']!;
      final counterparty = doc.json['counterparty'];

      // final operator = data['operator'];

      final qty = data['qty']!;

      final result = await Labels.connect(ip, port, (printer) async {
        setState(() => status = "registering");
        final record = await Api.feathers().create(serviceName: 'memories', data: {
          'document': docId,
          // 'operator': operator.id,
          'goods': goods.id,
          'uom': uom.id,
          'qty': qty
        }, params: {
          'oid': Api.instance.oid,
          'ctx': ['warehouse', 'dispatch', 'records']
        });

        setState(() => status = "printing");

        final id = record['_id'];

        final dd = DateFormat.yMMMMd().format(DateTime.parse(date));

        final Map<String, String> labelData = {
          "материал": goods.name(),
          "дата": dd,
          "количество": "$qty шт",
          "line1": "",
          "поставщик": counterparty.name(),
          // "оператор": operator.name(),
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
