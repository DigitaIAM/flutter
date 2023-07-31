import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/app_localizations.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/widgets/app_text_button.dart';

class SaveCancelButtons extends StatefulWidget {
  const SaveCancelButtons({
    super.key,
    required this.entity,
    this.isEnabled = true,
    this.isHeader = true,
    this.isCancelEnabled = false,
    this.saveLabel,
    this.cancelLabel,
    this.onSave,
    this.onCancel,
  });

  final MemoryItem entity;

  final bool isEnabled;
  final bool isHeader;

  final bool isCancelEnabled;

  final String? saveLabel;
  final String? cancelLabel;

  final Function(BuildContext)? onSave;
  final Function(BuildContext)? onCancel;

  @override
  State<SaveCancelButtons> createState() => _SaveCancelButtonsState();
}

class _SaveCancelButtonsState extends State<SaveCancelButtons> {
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocBuilder<MemoryBloc, RequestState>(
      builder: (context, state) {
        // print('state.saved ${state.saved}');
        if (state.saved != null) {
          // print('state.saved != null');
          if (state.saved!.updatedAt > widget.entity.updatedAt) {
            // print('updatedAt changed2');
            setState(() {
              saving = false;
            });
          }
        }
        // if (isMobile(context))
        if (saving) {
          return const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        } else {
          return Row(
            crossAxisAlignment: widget.isHeader ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
            children: <Widget>[
              if (widget.onCancel != null)
                Builder(builder: (BuildContext context) {
                  return AppTextButton(
                    label: _cancelLabel(localization),
                    isHeader: widget.isHeader && (widget.isEnabled || widget.isCancelEnabled),
                    onPressed: widget.isEnabled || widget.isCancelEnabled ? () => widget.onCancel?.call(context) : null,
                  );
                }),
              Builder(builder: (BuildContext context) {
                return AppTextButton(
                  label: _saveLabel(localization),
                  isHeader: widget.isHeader,
                  onPressed: widget.isEnabled || !saving
                      ? () {
                          setState(() {
                            saving = true;
                          });
                          widget.onSave?.call(context);
                        }
                      : null,
                );
              }),
            ],
          );
        }
      },
    );
  }

  String _saveLabel(AppLocalizations localization) {
    if (widget.saveLabel != null && widget.saveLabel!.isNotEmpty) {
      return widget.saveLabel!;
    }
    if (saving) {
      return localization.translate("saving");
    } else {
      return localization.translate("save");
    }
    // switch (state.saveStatus) {
    //   case SaveStatus.ready:
    //     return localization.translate("save");
    //   case SaveStatus.saving:
    //     return localization.translate("saving");
    //   case SaveStatus.success:
    //     return localization.translate("saved");
    //   case SaveStatus.failure:
    //     return localization.translate("error");
    // }
  }

  String _cancelLabel(AppLocalizations localization) {
    if (widget.cancelLabel != null && widget.cancelLabel!.isNotEmpty) {
      return widget.cancelLabel!;
    }

    return localization.translate("cancel");
  }
}
