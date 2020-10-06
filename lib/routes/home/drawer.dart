import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../index.dart';

class VideoTypeList extends StatelessWidget {
  Function(VideoSourceType) onTap;
  VideoTypeList({this.onTap});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 80,
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              '视频源分类',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
        _builderContent(),
      ],
    );
  }

  Widget _builderContent() {
    return Consumer<VideoSourceState>(
      builder: (context, videoSourceState, child) {
        return videoSourceState.sourceList.length == 0
            ? Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  '请先导入视频源',
                  style: TextStyle(
                    // color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    ...videoSourceState.sourceList
                        .map((sourceType) => VideoTypeListTitle(
                              sourceType: sourceType,
                              onTap: onTap,
                            ))
                  ]),
                ),
              );
      },
    );
  }
}

class VideoTypeListTitle extends StatelessWidget {
  VideoTypeListTitle({this.sourceType, this.onTap});
  VideoSourceType sourceType;
  void Function(VideoSourceType) onTap;

  void onTypepress({BuildContext context}) {
    if (onTap != null) {
      onTap(sourceType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoSourceState>(
      builder: (context, videoSourceState, child) {
        return Material(
          color: videoSourceState.currentSouce.id == sourceType.id
              ? Theme.of(context).primaryColor
              : Colors.white,
          child: InkWell(
            onTap: () => onTypepress(context: context),
            child: Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFCCCCCC),
                  ),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                sourceType.name,
                style: TextStyle(
                  fontSize: 16,
                  color: videoSourceState.currentSouce.id == sourceType.id
                      ? Colors.white
                      : Color.fromRGBO(33, 33, 33, 1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
