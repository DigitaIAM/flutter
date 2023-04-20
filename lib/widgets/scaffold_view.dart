import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/widgets/copy_to_clipboard.dart';
import 'package:nae/wrapper.dart';

class ScaffoldView extends StatelessWidget {
  // final BaseEntity entity;
  final PreferredSizeWidget? appBarBottom;
  final Widget body;
  final String title;
  final void Function()? onClose;

  const ScaffoldView({
    super.key,
    required this.body,
    // required this.entity,
    this.appBarBottom,
    this.title = "",
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Widget leading = IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        if (onClose == null) {
          context.read<UiBloc>().add(ChangeView(const [], action: 'view'));
        } else {
          onClose?.call();
        }
      },
    );

    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          leading: leading,
          automaticallyImplyLeading: uiState.isMobile,
          centerTitle: false,
          title: CopyToClipboard(
            value: title,
            child: Text(title),
          ),
          bottom: appBarBottom,
        ),
        body: SafeArea(
          child: body,
        ),
      ),
    );
  }
}
