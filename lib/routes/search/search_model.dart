import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../utils/debounce.dart';

import '../../index.dart';

class SearchModel {
  final BuildContext context;
  final TextEditingController controller;
  SearchModel({@required this.context, @required this.controller}) {
    _deGetDate = debounce(getXmlData);
  }

  Function _deGetDate;
  getXmlData({
    String path: '',
  }) async {
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context, listen: false);
    final VideoSearchState videoSearchState =
        Provider.of<VideoSearchState>(context, listen: false);
    videoSearchState.setLoding(true);
    try {
      final xmlListData = await HHttpClient(
        context,
        videoSourceState.currentSouce.httpsApi,
      ).netGet(path, {
        'ac': 'list',
        'pg': videoSearchState.pagination.page,
        'wd': controller.text,
      });
      XmlListResultModel xmlResultModel =
          ParseXmlToModel.xmlSearchToModel(xmlListData.toString());
      var xmlVideoData;
      List<VideoCardType> videoList = [];
      videoSearchState.setLoding(true);
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
      videoSearchState.loading = false;
      videoSearchState.setPagination(xmlResultModel.pagination);
      videoSearchState.setVideoList(videoList);
    } catch (e) {
      videoSearchState.setLoding(false);

      Fluttertoast.showToast(msg: e.toString());
      // print(e);
    }
  }

  void toNextPage() {
    final VideoSearchState videoSearchState =
        Provider.of<VideoSearchState>(context, listen: false);
    videoSearchState.nextPage();
    _deGetDate();
  }

  void toPrevPage() {
    final VideoSearchState videoSearchState =
        Provider.of<VideoSearchState>(context, listen: false);
    videoSearchState.prevPage();
    _deGetDate();
  }

  void toFirstPage() {
    final VideoSearchState videoSearchState =
        Provider.of<VideoSearchState>(context, listen: false);
    videoSearchState.firstPage();
    _deGetDate();
  }

  void toLastPage() {
    final VideoSearchState videoSearchState =
        Provider.of<VideoSearchState>(context, listen: false);
    videoSearchState.lastPage();
    _deGetDate();
  }

  void toSkipPage(int page) {
    final VideoSearchState videoSearchState =
        Provider.of<VideoSearchState>(context, listen: false);
    videoSearchState.skipPage(page);
    _deGetDate();
  }
}
