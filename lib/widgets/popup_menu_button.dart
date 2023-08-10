import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/event.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/schema/schema.dart';

class DocumentPopupMenuButton extends StatelessWidget {
  final Function()? showStorages;
  final String docId;
  final List<String> ctx;
  final List<Field> schema;
  final MemoryItem item;
  final String? status;

  const DocumentPopupMenuButton(
      {Key? key,
      this.showStorages,
      required this.docId,
      required this.ctx,
      required this.schema,
      required this.item,
      this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);

    final deleteButtonText = status == 'deleted' ? localization.translate("restore") : localization.translate("delete");

    List<PopupMenuEntry<int>> items = [
      PopupMenuItem(
        value: 1,
        child: Text(deleteButtonText),
      ),
    ];

    if (showStorages != null) {
      items.add(PopupMenuItem(
        value: 2,
        child: Text(localization.translate("show storages")),
      ));
    }

    return PopupMenuButton<int>(
      itemBuilder: (context) => items,
      offset: const Offset(0, 100),
      color: theme.primaryColorDark,
      elevation: 2,
      onSelected: (value) {
        if (value == 1) {
          final Map<String, dynamic> data = {};

          final innerStatus = status == 'deleted' ? null : 'deleted';
          data[sStatus] = innerStatus;

          patch(context, item, data);
        } else if (value == 2) {
          if (showStorages != null) {
            showStorages!();
          }
        }
      },
    );
  }

  void patch(BuildContext context, MemoryItem item, Map<String, dynamic> data) {
    if (item.isNew) {
      data['document'] = docId;
      context.read<MemoryBloc>().add(MemoryCreate('memories', ctx, schema, data));
    } else {
      context.read<MemoryBloc>().add(MemoryPatch('memories', ctx, schema, item.id, data));
    }
  }
}
