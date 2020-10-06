import 'package:flutter/material.dart';
import 'package:h_player_flutter/widgets/empty.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';
import '../../index.dart';
import '../video_card_widget.dart';

class HomeTabView extends StatelessWidget {
  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<VideoTypeState>(
  //     builder: (context, videoTypeState, child) {
  //       return Container(
  //         child: Row(
  //           children: videoTypeState.list.map((tab) {
  //           return Center(child: switchUI());
  //         }).toList(),
  //         ),
  //       );
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoCardState>(
      builder: (context, videoCardState, child) {
        if (videoCardState.loading &&
            videoCardState.videoCardList.length == 0) {
          return LoadingBouncingGrid.circle(
            backgroundColor: Theme.of(context).primaryColor,
          );
        } else if (!videoCardState.loading &&
            videoCardState.videoCardList.length == 0) {
          return Empty();
        } else {
          return VideoGridView();
        }
      },
    );
  }
}

class VideoGridView extends StatelessWidget {
  ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  void _scrollTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoCardState>(
      builder: (context, videoCardState, child) {
        return Stack(
          children: [
            GridView.extent(
              controller: _scrollController,
              padding:
                  EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 60),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              maxCrossAxisExtent: 290.0,
              childAspectRatio: 0.5,
              children: videoCardState.videoCardList
                  .map((e) => VideoCard(key: Key(e.id), video: e))
                  .toList(),
            ),
            Positioned(
              right: 18,
              bottom: 80,
              child: FloatingActionButton(
                heroTag: 1,
                onPressed: () => _scrollTop(),
                child: Icon(Icons.navigation),
                mini: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
