import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae_hr/models/ui/bloc.dart';
import 'package:nae_hr/widgets/help_text.dart';

import '../models/ui/state.dart';

class BlankScreen extends StatelessWidget {
  final String? message;

  const BlankScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(
        builder: (context, uiState) => Scaffold(
              appBar: AppBar(
                centerTitle: false,
                automaticallyImplyLeading: uiState.isMobile,
              ),
              body: Container(
                color: Theme.of(context).cardColor,
                child: HelpText(message: message ?? ''),
              ),
            ));
  }
}
