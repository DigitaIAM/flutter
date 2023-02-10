import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/models/memory/bloc.dart';
import 'package:nae_hr/models/memory/item.dart';
import 'package:nae_hr/models/memory/state.dart';
import 'package:nae_hr/models/ui/bloc.dart';
import 'package:nae_hr/widgets/menu_drawer_builder.dart';
import 'package:nae_hr/widgets/save_cancel_buttons.dart';

import '../models/ui/state.dart';

class EditScaffold extends StatelessWidget {
  const EditScaffold(
      {super.key,
      required this.entity,
      required this.title,
      required this.body,
      this.saveLabel,
      required this.onSave,
      required this.onCancel,
      required this.onClose});

  final MemoryItem entity;
  final String title;
  final Widget body;

  final String? saveLabel;

  final Function(BuildContext)? onSave;
  final Function(BuildContext)? onCancel;
  final Function(BuildContext) onClose;

  @override
  Widget build(BuildContext context) {
    bool isCancelEnabled = false;

    final showOverflow = false; // TODO isDesktop(context) && uiState.isFullScreen;

    return WillPopScope(
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
                        builder: (context, memState) => Scaffold(
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
                                  // if (isMobile(context))
                                  if (memState.saveStatus == SaveStatus.saving)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Center(
                                          child: SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(color: Colors.white),
                                      )),
                                    )
                                  else
                                    SaveCancelButtons(
                                        isEnabled: isEnabled(memState) && onSave != null,
                                        isHeader: true,
                                        isCancelEnabled: isCancelEnabled,
                                        saveLabel: saveLabel,
                                        onSave: (context) {
                                          // prevent form become changed and to hide the keyboard
                                          FocusScope.of(context)
                                              .unfocus(disposition: UnfocusDisposition.previouslyFocusedChild);
                                          onSave?.call(context);
                                        },
                                        onCancel: (context) {
                                          onCancel?.call(context);
                                        })

                                  // else
                                  //   Row(
                                  //     children: []
                                  //   )
                                ]),
                            body: Stack(alignment: Alignment.topCenter, children: [
                              Column(children: [
                                Expanded(
                                  child: body,
                                ),
                              ])
                            ])))))));
  }

  bool isEnabled(RequestState state) {
    // entity?.isEditable ?? true
    return state.saveStatus == SaveStatus.ready || state.saveStatus == SaveStatus.failure;
  }
}
