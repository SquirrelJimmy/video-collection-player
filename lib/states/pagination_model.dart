import 'package:flutter/material.dart';

import '../index.dart';

class PaginationState extends ChangeNotifier {
  Pagination _pagination = Pagination.fromJson(
      {"page": 1, "pagecount": 0, "pagesize": 30, "recordcount": 0});

  int get currentPage => _pagination.page;
  int get pageSize => _pagination.pagesize;
  int get totalRecord => _pagination.recordcount;
  int get totalPage => _pagination.pagecount;

  void init() {
    // _pagination = Pagination.fromJson(
    //     {"page": 1, "pagecount": 0, "pagesize": 30, "recordcount": 0});
    notifyListeners();
  }

  void setPagination(Pagination pagination) {
    _pagination = pagination;
    notifyListeners();
  }

  void nextPage() {
    _pagination.page++;
    if (_pagination.page >= _pagination.pagecount) {
      _pagination.page = _pagination.pagecount;
    }
    notifyListeners();
  }

  void prevPage() {
    _pagination.page--;
    if (_pagination.page <= 1) {
      _pagination.page = 1;
    }
    notifyListeners();
  }

  void lastPage() {
    _pagination.page = _pagination.pagecount;
    notifyListeners();
  }

  void firstPage() {
    _pagination.page = 1;
    notifyListeners();
  }

  void setPage(int page) {
    if (page >= _pagination.pagecount) {
      page = _pagination.pagecount;
    } else if (page <= 1) {
      _pagination.page = 1;
    } else {
      _pagination.page = page;
    }
    notifyListeners();
  }
}
