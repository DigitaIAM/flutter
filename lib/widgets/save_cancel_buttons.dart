
import 'package:flutter/material.dart';
import 'package:nae_hr/app_localizations.dart';
import 'package:nae_hr/widgets/app_text_button.dart';

class SaveCancelButtons extends StatelessWidget {
  const SaveCancelButtons({super.key,
    this.isEnabled = true,
    this.isHeader = true,
    this.isCancelEnabled = false,
    this.saveLabel, this.cancelLabel, this.onSave, this.onCancel,
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

    return Row(
      crossAxisAlignment: isHeader ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: <Widget>[
        if (onCancel != null)
          Builder(builder: (BuildContext context) {
            return AppTextButton(
              label: cancelLabel ?? localization.translate("cancel"),
              isHeader: isHeader && (isEnabled || isCancelEnabled),
              onPressed: isEnabled || isCancelEnabled ? () => onCancel?.call(context) : null,
            );
          }),
        Builder(builder: (BuildContext context) {
          return AppTextButton(
            label: saveLabel ?? localization.translate("save"),
            isHeader: isHeader,
            onPressed: isEnabled ? () => onSave?.call(context) : null,
          );
        }),
      ]
    );
  }
}