import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:h_player_flutter/index.dart';

class CollectionState extends ChangeNotifier {

  CollectionState(): super() {
    final cache = Global.prefs.getString(_key);
    if (cache != null){
      final Iterable listIterable = jsonDecode(cache);
      _list = List<Map<String, dynamic>>.from(listIterable)
          .map((item) => VideoCardType.fromJson(item))
          .toList();
    }
  }
  String _key = 'collection_videos';
  List<VideoCardType> _list = [];
  List<VideoCardType> get list => _list;
  List<String> get idList => _list.map((e) => e.id).toList();


  void setCollection(VideoCardType videoCard) {
    final name = videoCard.name;
    final id = videoCard.id;

    if(_list.length == 0) {
      _list.add(videoCard);
    } else {
      final el = _list.firstWhere((card) => card.name == videoCard.name && card.id == videoCard.id, orElse: () => null);
      // print(el?.name);
      if (el == null) {
        _list.add(videoCard);
      } else {
        // print(_list.remove(el));
        _list.remove(el);

      }
    }
    notifyListeners();
  }

  @override
  void notifyListeners() {
    Global.prefs.setString(_key, jsonEncode(_list));
    super.notifyListeners();
  }
}
