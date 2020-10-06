import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/index.dart';
import '../common/index.dart';

class VideoSourceState extends ChangeNotifier {
  VideoSourceState() {
    // Global.prefs.clear();
    final cache = Global.prefs.getString(_key);
    if (cache != null) {
      final Iterable listIterable = jsonDecode(cache);
      sourceList = List<Map<String, dynamic>>.from(listIterable)
          .map((item) => VideoSourceType.fromJson(item))
          .toList();
      currentSouce = sourceList[0];
    }
  }

  final String _key = 'videoSourList';
  VideoSourceType currentSouce;
  List<VideoSourceType> sourceList = [];

  void setList(List<VideoSourceType> list) {
    if (list.length == 0) return;
    sourceList = list;
    currentSouce = list[0];
    notifyListeners();
  }

  void setCurrentSource(VideoSourceType type) {
    currentSouce = type;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    Global.prefs.setString(_key, jsonEncode(sourceList));
    super.notifyListeners();
  }
}
