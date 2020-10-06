import 'package:flutter/material.dart';
import 'package:h_player_flutter/index.dart';
import 'package:h_player_flutter/routes/video_card_widget.dart';
import 'package:h_player_flutter/widgets/empty.dart';
import 'package:h_player_flutter/widgets/pagination.dart';
import 'package:provider/provider.dart';

// import '../video_card_widget.dart';

class CollotionPage extends StatefulWidget {

  @override
  _CollotionPage createState() => _CollotionPage();
}


class _CollotionPage extends State<CollotionPage> {

  // VideoCardType _oldVideo;
  List<VideoCardType> get _list =>  Provider.of<CollectionState>(context, listen: false).list;
  List<VideoCardType> _renderList;
  int _lowRange = 0;
  int _heightRange;
  int get _maxRange => _list.length > 0 ? _list.length : 0;
  int get _maxPage => (_list.length / 20).ceil();
  int get _page => (_heightRange / 20).ceil();

  ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  void _scrollTop() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _nextPage() {
    if(_page >= _maxPage) return;
    setState(() {
      _lowRange = _heightRange;
      _heightRange = _heightRange + 20 >= _list.length ? _list.length :  _heightRange + 20;
    });
  }

  void _prevPage() {
    if(_page <= 1) return;
    setState(() {
      _heightRange = _lowRange;
      _lowRange = _lowRange - 20 <= 0 ? 0 :  _lowRange - 20;
    });
  }

  void _firstPage() {
    setState(() {
      _heightRange = _list.length > 20 ? 20 :  _list.length;
      _lowRange = 0;
    });
  }

  void _lastPage() {
    setState(() {
      _heightRange = _list.length;
      _lowRange =  _list.length % 20 > 0 ? _list.length - _list.length % 20 : _list.length - 20;
    });
  }

  void _toPage(String p) {
    int page = int.parse(p);
    if(page >= _maxPage) {
      _lastPage();
      return;
    }

    if(page <= 0) {
      _firstPage();
      return;
    }
    _heightRange = page * 20;
    _lowRange = _heightRange - 20;
  }


  void _upDateRange() {
    if(_heightRange >= _maxRange) {
      setState(() {
        _heightRange = _maxRange;
        _lowRange = _heightRange - 20 <= 0 ? 0 : _heightRange - 20;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _oldVideo = Provider.of<VideoCardState>(context, listen: false).currentVideoInfo;
    // _list = Provider.of<CollectionState>(context, listen: false).list;
    _heightRange = _list.length > 20 ? 20 :  _list.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏'),
      ),
      body: _list.length > 0 ? buildContent() : Empty(),
    );
  }

  Widget buildContent() {

    return Stack(
      children: [
        GridView.extent(
          controller: _scrollController,
          padding:
          EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 60),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          maxCrossAxisExtent: 290.0,
          childAspectRatio: 0.5,
          children: _list.getRange(_lowRange, _heightRange)
              .map((e) => VideoCard(key: Key(e.id), video: e, onToggleCollection: () {
            _upDateRange();
          },
          ))
              .toList(),
        ),
        Positioned(
          right: 18,
          bottom: 80,
          child: FloatingActionButton(
            heroTag: 1,
            onPressed: () => _scrollTop(),
            child: Icon(Icons.navigation),
            mini: true,
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: Color(0xFFFFFFFF),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 50,
            padding: EdgeInsets.only(top: 6),
            child: PaginationControl(
              page: _page,
              maxPage: _maxPage,
              toNextPage: _nextPage,
              toPrevPage: _prevPage,
              toFirstPage: _firstPage,
              toLastPage: _lastPage,
              toSkipPage: _toPage,
            ),
          ),
        )
      ],
    );
  }
}