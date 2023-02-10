import 'package:flutter/material.dart';
import 'package:nae_hr/constants.dart';
import 'package:nae_hr/widgets/app_border.dart';

class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    this.child,
    this.children,
    this.isLast = false,
    this.elevation = 5,
    this.padding,
    this.internalPadding,
    this.crossAxisAlignment,
    this.constraints,
  });

  final bool isLast;
  final double elevation;

  final EdgeInsets? padding;
  final EdgeInsets? internalPadding;
  final CrossAxisAlignment? crossAxisAlignment;
  final BoxConstraints? constraints;

  final Widget? child;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    if (child == null && (children?.isEmpty ?? true)) {
      return const SizedBox();
    }

    return Padding(
        padding: EdgeInsets.only(
          left: cMobileDialogPadding,
          top: cMobileDialogPadding,
          right: cMobileDialogPadding,
          bottom: isLast ? cMobileDialogPadding : 0,
        ),
        child: FocusTraversalGroup(
            child: Card(
                elevation: elevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cBorderRadius),
                ),
                child: AppBorder(
                    // hideBorder: !isDarkMode(context),
                    child: Padding(
                  padding: internalPadding ?? const EdgeInsets.all(16),
                  child: child ??
                      Container(
                        width: double.infinity,
                        constraints: constraints,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
                          children: children!,
                        ),
                      ),
                )))));
  }
}
