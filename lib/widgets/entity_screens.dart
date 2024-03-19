import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nae/core/my_settings.dart';
import 'package:nae/models/memory/bloc.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/models/memory/state.dart';
import 'package:nae/models/ui/bloc.dart';
import 'package:nae/models/ui/state.dart';
import 'package:nae/schema/schema.dart';
import 'package:nae/widgets/app_border.dart';
import 'package:nae/widgets/memory_list.dart';
import 'package:provider/provider.dart';

abstract class EntityHolder extends StatefulWidget {
  const EntityHolder({
    super.key,
    required this.entity,
    this.fullscreen = false,
  });

  final MemoryItem entity;
  final bool fullscreen;

  bool anythingToShow() {
    return entity.id.isNotEmpty;
  }
}

class EntityScreens extends StatelessWidget {
  final List<String> ctx;
  final List<Field>? schema;
  final Widget list;
  final EntityHolder view;

  const EntityScreens({
    super.key,
    required this.ctx,
    required this.list,
    required this.view,
    this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UiBloc, UiState>(
      builder: (context, uiState) => MemoryBlocHolder(
        // initial load trigger at list widgets
        // init: (bloc) => ctx.isNotEmpty ? bloc.add(MemoryFetch("memories", ctx, schema: schema)) : null,
        child: screens(context, uiState),
      ),
    );
  }

  Widget screens(BuildContext context, UiState uiState) {
    return BlocBuilder<MemoryBloc, RequestState>(
      buildWhen: (o, n) => o.status != n.status,
      builder: (context, state) => Row(
          key: ValueKey('__${ctx.join('_')}_'), // ${state.updated}
          children: uiState.isFullScreen
              ? smallScreen(context, uiState, state)
              : bigScreen(context, uiState, state)),
    );
  }

  List<Widget> smallScreen(
    BuildContext context,
    UiState uiState,
    RequestState state,
  ) {
    // print("smallScreen: ${view.anythingToShow()}");
    const previewFlex = 2;
    int listFlex = 3;

    if (view.anythingToShow()) {
      return [
        Expanded(
          flex: uiState.isFullScreen ? (listFlex + previewFlex) : previewFlex,
          child: AppBorder(
            isLeft: true,
            child: view,
          ),
        ),
      ];
    } else {
      return [
        Expanded(
          flex: listFlex,
          child: ClipRRect(child: list),
        ),
      ];
    }
  }

  List<Widget> bigScreen(
    BuildContext context,
    UiState uiState,
    RequestState state,
  ) {
    // print("bigScreen: ${view.anythingToShow()}");
    final settings = Provider.of<MySettings>(context);

    const previewFlex = 2;
    int listFlex = 3;

    Widget? topFilterChild;
    // topFilterChild = EntityTopFilter(
    //   show: uiState.filterEntityType != null,
    // );
    Widget? leftFilterChild;
    return [
      if (!(view.fullscreen && view.anythingToShow()))
        Expanded(
          key: ValueKey('__${ctx.join('_')}_${state.updated}'),
          flex: listFlex,
          child: ClipRRect(
            child: AppBorder(
              isLeft: leftFilterChild != null,
              child: topFilterChild == null || settings.isFilterVisible
                  ? list
                  : Column(
                      children: [
                        // if (prefState.isViewerFullScreen(state.uiState.filterEntityType))
                        //   SizedBox(
                        //     height: 360,
                        //     child: topFilterChild,
                        //   )
                        // else
                        topFilterChild,
                        Expanded(
                          child: AppBorder(
                            isTop: topFilterChild !=
                                null, // && uiState.filterEntityType != null,
                            child: list,
                          ),
                        )
                      ],
                    ),
            ),
          ),
        ),
      if (view.anythingToShow())
        Expanded(
          flex: uiState.isFullScreen ? (listFlex + previewFlex) : previewFlex,
          child: AppBorder(
            isLeft: true,
            child: view,
          ),
        ),
    ];
  }
}
