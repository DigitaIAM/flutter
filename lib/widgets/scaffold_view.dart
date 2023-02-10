import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/event.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/widgets/copy_to_clipboard.dart';

class ScaffoldView extends StatelessWidget {
  // final BaseEntity entity;
  final PreferredSizeWidget? appBarBottom;
  final Widget body;

  const ScaffoldView({
    super.key,
    required this.body,
    // required this.entity,
    this.appBarBottom,
  });

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "";

    Widget leading = IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        context.read<UiBloc>().add(ChangeView(const [], action: 'view'));
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
            value: appBarTitle,
            child: Text(appBarTitle),
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
