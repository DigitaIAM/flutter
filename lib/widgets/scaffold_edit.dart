import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/widgets/menu_drawer_builder.dart';
import 'package:nae/widgets/save_cancel_buttons.dart';

import '../models/ui/state.dart';

class EditScaffold extends StatelessWidget {
  const EditScaffold({
    super.key,
    required this.entity,
    required this.title,
    required this.body,
    this.saveLabel,
    this.afterSave,
    required this.onSave,
    required this.onCancel,
    required this.onClose,
  });

  final MemoryItem entity;
  final String title;
  final Widget body;

  final String? saveLabel;

  final Function(BuildContext, MemoryItem)? afterSave;

  final Function(BuildContext)? onSave;
  final Function(BuildContext)? onCancel;
  final Function(BuildContext) onClose;

  @override
  Widget build(BuildContext context) {
    bool isCancelEnabled = false;

    final showOverflow = false; // TODO isDesktop(context) && uiState.isFullScreen;

    return BlocListener<MemoryBloc, RequestState>(
      listener: (context, state) {
        if (state.isUpdated(entity)) {
          if (afterSave != null) {
            afterSave?.call(context, state.saved!);
          } else {
            onClose(context);
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Focus(
          onKey: (node, event) {
            if (LogicalKeySet(LogicalKeyboardKey.escape).accepts(event, RawKeyboard.instance)) {
              onClose(context);

              return KeyEventResult.handled;
            } else if (LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS)
                    .accepts(event, RawKeyboard.instance) ||
                const SingleActivator(LogicalKeyboardKey.keyS, control: true).accepts(event, RawKeyboard.instance)) {
              print("ctrl+s");
              onSave?.call(context);

              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: BlocBuilder<UiBloc, UiState>(
            builder: (context, uiState) => FocusTraversalGroup(
              child: BlocBuilder<MemoryBloc, RequestState>(
                builder: (context, memState) {
                  return Scaffold(
                    drawer: uiState.isDesktop ? const MenuDrawerBuilder() : null,
                    appBar: AppBar(
                        centerTitle: false,
                        automaticallyImplyLeading: uiState.isMobile,
                        title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (showOverflow) Text(title) else Flexible(child: Text(title)),
                            ]),
                        actions: [
                          SaveCancelButtons(
                            entity: entity,
                            isEnabled: onSave != null || onCancel != null,
                            isHeader: true,
                            isCancelEnabled: isCancelEnabled,
                            saveLabel: saveLabel,
                            onSave: (context) {
                              // prevent form become changed and to hide the keyboard
                              FocusScope.of(context).unfocus(disposition: UnfocusDisposition.previouslyFocusedChild);
                              onSave?.call(context);
                            },
                            onCancel: onCancel,
                          )
                        ]),
                    body: Stack(alignment: Alignment.topCenter, children: [
                      Column(children: [
                        Expanded(
                          child: body,
                        ),
                      ])
                    ]),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
