import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../index.dart';

class HomePageState {
  HomePageState(this.context);

  BuildContext context;

  VideoSourceType _cacheCurrentSouce;

  getXmlData({
    String path: '',
    Map<String, dynamic> queryParameters,
  }) async {
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context, listen: false);
    final VideoTypeState videoTypeState =
        Provider.of<VideoTypeState>(context, listen: false);
    final PaginationState paginationState =
        Provider.of<PaginationState>(context, listen: false);

    final VideoCardState videoCardState =
        Provider.of<VideoCardState>(context, listen: false);
    if (videoSourceState.sourceList.length <= 1) return;
    try {
      final xmlListData = await HHttpClient(
        context,
        videoSourceState.currentSouce.httpsApi,
      ).netGet(path, {
        'ac': 'list',
        'pg': 1,
        ...queryParameters ?? {},
      });
      // log(xmlListData.toString());

      XmlListResultModel xmlResultModel =
          ParseXmlToModel.fromXmlList(xmlListData.toString());
      var xmlVideoData;
      List<VideoCardType> videoList = [];
      if (xmlResultModel.videoIdList.length > 0) {
        xmlVideoData = await HHttpClient(
          context,
          videoSourceState.currentSouce.httpsApi,
        ).netGet(
          path,
          {
            'ac': 'videolist',
            'ids': xmlResultModel.videoIdList.join(','),
          },
        );
        videoList =
            ParseXmlToModel.xmlVideoResultModel(xmlVideoData.toString());
      }

      if (_cacheCurrentSouce == null ||
          (_cacheCurrentSouce.id != videoSourceState.currentSouce.id)) {
        videoTypeState.setList(xmlResultModel.videoTypeList);
      }
      videoCardState.setVideoList(videoList ?? []);
      paginationState.setPagination(xmlResultModel.pagination);
      videoCardState.setLoading(false);
      _cacheCurrentSouce = videoSourceState.currentSouce;
    } catch (e) {
      videoCardState.setLoading(false);
      Fluttertoast.showToast(msg: e.toString());
      // print(e);
    }
  }

  void toCollection(VideoSourceType _sourceType) {}

  static void toSwitchVideoSource(
      BuildContext context, VideoSourceType sourceType) {
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context, listen: false);
    // final VideoTypeState videoTypeState =
    //     Provider.of<VideoTypeState>(context, listen: false);
    final VideoCardState videoCardState =
        Provider.of<VideoCardState>(context, listen: false);
    videoSourceState.setCurrentSource(sourceType);
    // videoTypeState.setList([]);
    videoCardState.setVideoList([]);
  }

  static void toSwitchVideoType(BuildContext context, VideoType type) {
    final VideoTypeState videoTypeState =
        Provider.of<VideoTypeState>(context, listen: false);
    final VideoCardState videoCardState =
        Provider.of<VideoCardState>(context, listen: false);
    videoTypeState.setCurrentType(type);
    videoCardState.setVideoList([]);
  }
}
