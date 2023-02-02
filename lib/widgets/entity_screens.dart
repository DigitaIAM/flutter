
import 'package:flutter/material.dart';
import 'package:nae_hr/core/my_settings.dart';
import 'package:nae_hr/model/memory/item.dart';
import 'package:nae_hr/widgets/app_border.dart';
import 'package:provider/provider.dart';

abstract class EntityHolder extends StatefulWidget {
  const EntityHolder({super.key, required this.entity});

  final MemoryItem entity;

  bool anythingToShow() {
    return entity.id.isNotEmpty;
  }
}

class EntityScreens extends StatelessWidget {

  final Widget list;
  final EntityHolder view;

  const EntityScreens({super.key,
    required this.list, required this.view
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<MySettings>(context);

    const previewFlex = 2;
    int listFlex = 3;

    Widget? topFilterChild;
    // topFilterChild = EntityTopFilter(
    //   show: uiState.filterEntityType != null,
    // );
    Widget? leftFilterChild;

    return Row(
        children: [
          Expanded(
            flex: listFlex,
            child: ClipRRect(
              child: AppBorder(
                isLeft: leftFilterChild != null,
                child: topFilterChild == null || settings.isFilterVisible
                    ? list : Column(children: [
                  // if (prefState.isViewerFullScreen(state.uiState.filterEntityType))
                  //   SizedBox(
                  //     height: 360,
                  //     child: topFilterChild,
                  //   )
                  // else
                  topFilterChild,
                  Expanded(
                    child: AppBorder(
                      isTop: topFilterChild != null, // && uiState.filterEntityType != null,
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
              flex: settings.isFullScreen ? (listFlex + previewFlex) : previewFlex,
              child: AppBorder(
                isLeft: true,
                child: view,
              ),
            ),
        ]
    );
  }
}
