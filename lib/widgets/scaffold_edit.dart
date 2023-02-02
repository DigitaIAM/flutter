
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/core/platform.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/model/memory/memory_bloc.dart';
import 'package:nae_hr/model/memory/memory_state.dart';
import 'package:nae_hr/model/ui/ui_bloc.dart';
import 'package:nae_hr/model/ui/ui_state.dart';
import 'package:nae_hr/widgets/menu_drawer_builder.dart';
import 'package:nae_hr/widgets/save_cancel_buttons.dart';

class EditScaffold extends StatelessWidget {
  const EditScaffold({super.key,
    required this.entity, required this.title, required this.body,
    this.saveLabel,
    required this.onSave, required this.onCancel, required this.onClose
  });

  final MemoryItem entity;
  final String title;
  final Widget body;

  final String? saveLabel;

  final Function(BuildContext)? onSave;
  final Function(BuildContext)? onCancel;
  final Function(BuildContext) onClose;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    bool isEnabled = true; // !uiState.isSaving && (entity?.isEditable ?? true);
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
          } else if (
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS).accepts(event, RawKeyboard.instance)
            || const SingleActivator(LogicalKeyboardKey.keyS, control: true).accepts(event, RawKeyboard.instance)
          ) {
            print("ctrl+s");
            onSave?.call(context);

            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Builder(
          builder: (context) => FocusTraversalGroup(
            child: BlocBuilder<MemoryBloc, RequestState>(
              builder: (context, memState) => Scaffold(
                drawer: isDesktop(context) ? const MenuDrawerBuilder() : null,
                appBar: AppBar(
                  centerTitle: false,
                  automaticallyImplyLeading: isMobile(context),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (showOverflow) Text(title) else Flexible(child: Text(title)),
                    ]
                  ),
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
                          isEnabled: isEnabled && onSave != null,
                          isHeader: true,
                          isCancelEnabled: isCancelEnabled,
                          saveLabel: saveLabel,
                          cancelLabel: localization.translate("cancel"),
                          onSave: (context) {
                            // prevent form become changed and to hide the keyboard
                            FocusScope.of(context).unfocus(disposition: UnfocusDisposition.previouslyFocusedChild);
                            onSave?.call(context);
                          },
                          onCancel: (context) {
                            onCancel?.call(context);
                          }
                      )

                    // else
                    //   Row(
                    //     children: []
                    //   )
                  ]
                ),
                body: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: body,
                        ),
                      ]
                    )
                  ]
                )
              )
            )
          )
        )
      )
    );
  }
}