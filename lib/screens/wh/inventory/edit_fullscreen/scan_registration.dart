import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/qty.dart';

import '../screen.dart';

class ScanRegistration extends StatefulWidget {
  final MemoryItem doc;

  const ScanRegistration({super.key, required this.doc});

  @override
  State<StatefulWidget> createState() => _ScanRegistrationState();
}

class _ScanRegistrationState extends State<ScanRegistration> {
  final textController = TextEditingController();

  final focusNode = FocusNode();

  String lang = 'EN';
  String scanText = '';
  String error = '';

  final mappingRU =
      'йцукенгшщзхъфывапролджячсмитьбю. ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ/ЯЧСМИТЬБЮ,';
  final mappingEN =
      'qwertyuiop[]asdfghjkl;zxcvbnm,./ QWERTYUIOP{}ASDFGHJKL:"|ZXCVBNM<>?';

  final rus = 'йцукенгшщзхъфывапролджячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
  final eng = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemoryBloc, RequestState>(
      listener: (context, state) {
        // do stuff here based on BlocA's state
      },
      builder: (context, state) => ListView(children: <Widget>[
        KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            // print("keyboard $event");
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                lang = 'EN';
                for (final ch in rus.characters) {
                  if (scanText.contains(ch)) {
                    lang = 'RU';
                    break;
                  }
                }
                if (lang == 'EN') {
                  textController.text = scanText;
                }
                final reference = textController.text;
                process(context, reference, state);
              } else {
                final char = event.character;
                if (char != null) {
                  scanText += char;
                  final index = mappingRU.indexOf(char);
                  if (index < 0) {
                    textController.text += char;
                  } else {
                    textController.text += mappingEN[index];
                  }
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Column(children: [
              TextFormField(
                readOnly: true,
                // focusNode: focusNode,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(
                    color: Color(0xFF6200EE),
                  ),
                  helperText: 'отсканируйте ТМЦ',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: textController,
              ),
              const SizedBox(height: 10),
              if (error.isNotEmpty) Text('ОШИБКА: $error !'),
              if (error.isEmpty) Text(state.saved?['goods']?.name() ?? ''),
              if (error.isEmpty)
                Text(state.saved?.json['batch']?['date'] ?? ''),
              if (error.isEmpty)
                Text(Qty.fromJson(state.saved?.json['qty']).toString())
            ]),
          ),
        ),
      ]),
    );
  }

  void process(
      BuildContext context, String reference, RequestState state) async {
    // print("reference $reference");
    setState(() {
      error = '';
    });
    try {
      if (state.status != RequestStatus.success) {
        setState(() {
          error = 'нет данных с сервера';
        });

        return;
      }

      for (final item in state.items) {
        if (item.json['reference'] == reference) {
          // print("item.json ${item.json}");
          setState(() {
            error = 'такой товар уже есть';
          });
          return;
        }
      }

      final res = await Api.feathers().get(
        serviceName: "memories",
        objectId: reference,
        params: {
          "oid": Api.instance.oid,
        },
      );

      // print("res $res");

      final docId = res[cDocument];
      if (docId != null) {
        final document = await Api.feathers().get(
          serviceName: "memories",
          objectId: docId,
          params: {'oid': Api.instance.oid},
        );

        // print("document $document");

        final data = {
          cDocument: widget.doc.id,
          'reference': reference,
          cGoods: document['product']['_id'],
          cBatch: {'id': document['_uuid'], 'date': document[cDate]},
          cQty: res[cQty],
          'customer': res['customer'],
          'label': res['label'],
        };

        // print("data $data");

        if (context.mounted) {
          context.read<MemoryBloc>().add(MemoryCreate(
              'memories', WHInventory.ctxOfRecord, const [], data));
        }
      }
    } finally {
      textController.text = '';
      scanText = '';
    }
  }
}
