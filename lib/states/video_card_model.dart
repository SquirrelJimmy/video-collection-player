import 'package:flutter/material.dart';
import '../index.dart';

class VideoCardState extends ChangeNotifier {
  VideoCardType currentVideoInfo;
  List<VideoCardType> videoCardList = [];
  bool loading = true;

  void setLoading(bool load) {
    loading = load;
    notifyListeners();
  }

  void setVideoList(List<VideoCardType> list) {
    videoCardList = list;
    // loading = false;
    notifyListeners();
  }

  void setCurrentVideo(VideoCardType videoCard) {
    currentVideoInfo = videoCard;
    notifyListeners();
  }
}
