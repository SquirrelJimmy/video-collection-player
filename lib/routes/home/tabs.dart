import 'package:flutter/material.dart';
import '../../models/index.dart';

class HomeTab extends StatelessWidget {
  HomeTab({Key key, VideoType tab}) : super(key: key) {
    _tab = tab;
  }
  VideoType _tab;
  String get id => _tab.id;
  @override
  Widget build(BuildContext context) {
    return Tab(
      text: _tab.label,
    );
  }
}
