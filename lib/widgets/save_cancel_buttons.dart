import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/models/memory/bloc.dart';
import 'package:nae_hr/models/memory/state.dart';
import 'package:nae_hr/widgets/app_text_button.dart';

class SaveCancelButtons extends StatelessWidget {
  const SaveCancelButtons({
    super.key,
    this.isEnabled = true,
    this.isHeader = true,
    this.isCancelEnabled = false,
    this.saveLabel,
    this.cancelLabel,
    this.onSave,
    this.onCancel,
  });

  final bool isEnabled;
  final bool isHeader;
  final bool isCancelEnabled;

  final String? saveLabel;
  final String? cancelLabel;

  final Function(BuildContext)? onSave;
  final Function(BuildContext)? onCancel;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocBuilder<MemoryBloc, RequestState>(
        builder: (context, state) => Row(
                crossAxisAlignment: isHeader ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
                children: <Widget>[
                  if (onCancel != null)
                    Builder(builder: (BuildContext context) {
                      return AppTextButton(
                        label: _cancelLabel(state, localization),
                        isHeader: isHeader && (isEnabled || isCancelEnabled),
                        onPressed: isEnabled || isCancelEnabled ? () => onCancel?.call(context) : null,
                      );
                    }),
                  Builder(builder: (BuildContext context) {
                    return AppTextButton(
                      label: _saveLabel(state, localization),
                      isHeader: isHeader,
                      onPressed: isEnabled ? () => onSave?.call(context) : null,
                    );
                  }),
                ]));
  }

  String _saveLabel(RequestState state, AppLocalizations localization) {
    if (saveLabel != null && saveLabel!.isNotEmpty) {
      return saveLabel!;
    }
    switch (state.saveStatus) {
      case SaveStatus.ready:
        return localization.translate("save");
      case SaveStatus.saving:
        return localization.translate("saving");
      case SaveStatus.success:
        return localization.translate("saved");
      case SaveStatus.failure:
        return localization.translate("error");
    }
  }

  String _cancelLabel(RequestState state, AppLocalizations localization) {
    if (cancelLabel != null && cancelLabel!.isNotEmpty) {
      return cancelLabel!;
    }

    return localization.translate("cancel");
  }
}
