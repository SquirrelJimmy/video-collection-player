import 'package:flutter/material.dart';
import '../index.dart';

class VideoTypeState extends ChangeNotifier {
  List<VideoType> list = [];
  VideoType currentVideoType = VideoType.fromJson({
    'id': '-9999',
    'label': '全部',
  });
  final VideoType initalType = VideoType.fromJson({
    'id': '-9999',
    'label': '全部',
  });
  void setList(List<VideoType> newList) {
    list = [initalType, ...newList];
    notifyListeners();
  }

  void setCurrentType(VideoType type) {
    currentVideoType = type;
    notifyListeners();
  }
}
