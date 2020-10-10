import 'package:flutter/material.dart';
import '../index.dart';

class VideoSearchState extends ChangeNotifier {
  List<VideoCardType> videoCardList = [];
  List<String> keywords = [];
  bool loading = false;
  Pagination pagination = Pagination.fromJson(
      {'page': 1, 'pagecount': 0, 'pagesize': 0, 'recordcount': 0});
  void setVideoList(List<VideoCardType> list) {
    videoCardList = list;
    notifyListeners();
  }

  void addKeyword(String keyword) {
    if (keywords.contains(keyword)) return;
    keywords.add(keyword);
    notifyListeners();
  }

  void setLoding(bool load) {
    loading = load;
    notifyListeners();
  }

  void setPagination(Pagination p) {
    pagination = p;
    notifyListeners();
  }

  void nextPage() {
    if (pagination.page >= pagination.pagecount) {
      pagination.page = pagination.pagecount;
    } else {
      pagination.page++;
    }
    notifyListeners();
  }

  void prevPage() {
    if (pagination.page <= 1) {
      pagination.page = 1;
    } else {
      pagination.page--;
    }
    notifyListeners();
  }

  void lastPage() {
    pagination.page = pagination.pagecount;
    notifyListeners();
  }

  void firstPage() {
    pagination.page = 1;
    notifyListeners();
  }

  void skipPage(int page) {
    pagination.page = page;
    notifyListeners();
  }
}
