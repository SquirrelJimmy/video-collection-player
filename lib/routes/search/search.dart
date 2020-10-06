import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:h_player_flutter/index.dart';
import 'package:h_player_flutter/widgets/empty.dart';
import 'package:h_player_flutter/widgets/pagination.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

import '../video_card_widget.dart';
import 'search_model.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchPage> {
  Color get _color => Theme.of(context).primaryColor;
  Size get _screenSize => MediaQuery.of(context).size;

  ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  List<VideoCardType> get _list =>
      Provider.of<VideoSearchState>(context).videoCardList;
  bool get _loading => Provider.of<VideoSearchState>(context).loading;
  VideoSourceType get _source =>
      Provider.of<VideoSourceState>(context).currentSouce;
  Pagination get _pagonation =>
      Provider.of<VideoSearchState>(context).pagination;

  SearchModel _model;
  TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1)).then((value) {
      final VideoSearchState videoSearchState =
          Provider.of<VideoSearchState>(context, listen: false);
      videoSearchState.setVideoList([]);
    });
    _controller = TextEditingController();
    _model = SearchModel(context: context, controller: _controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _onSearch() async {
    _model.getXmlData();
  }

  @override
  Widget build(BuildContext context) {
    print(_pagonation.pagecount);
    return Scaffold(
      appBar: AppBar(
        title: Text('${_source.name}'),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _screenSize.width,
            maxHeight: _screenSize.height,
          ),
          child: Stack(
            children: [
              _buildContent(),
              _searchBar(),
              _list.length > 0
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: PaginationControl(
                          page: _pagonation.page,
                          maxPage: _pagonation.pagecount,
                          toNextPage: _model.toNextPage,
                          toPrevPage: _model.toPrevPage,
                          toFirstPage: _model.toFirstPage,
                          toLastPage: _model.toLastPage,
                          toSkipPage: (page) =>
                              _model.toSkipPage(int.parse(page)),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      width: _screenSize.width,
      height: 50,
      // color: Colors.red,
      margin: EdgeInsets.only(top: 10),
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: _screenSize.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color.fromRGBO(142, 142, 147, .15),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Theme(
            child: TextField(
              keyboardType: TextInputType.text,
              // autofocus: true,
              controller: _controller,
              decoration: new InputDecoration(
                hintText: '输入搜索关键字',
                icon: Icon(Icons.search),
                border: InputBorder.none,
                suffix: GestureDetector(
                  onTap: () {
                    _controller.clear();
                  },
                  child: Icon(
                    Icons.clear,
                    size: 16,
                  ),
                ),
              ),
              onSubmitted: (value) => _onSearch(),
            ),
            data: Theme.of(context).copyWith(
              primaryColor: _color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return Center(
        child: LoadingBouncingGrid.circle(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    } else if (_list.length != 0) {
      return Container(
        margin: EdgeInsets.only(top: 70),
        child: GridView.extent(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 60),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          maxCrossAxisExtent: 290.0,
          childAspectRatio: 0.5,
          children:
              _list.map((e) => VideoCard(key: Key(e.id), video: e)).toList(),
        ),
      );
    } else {
      return Empty();
    }
  }
}
