import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:h_player_flutter/index.dart';
import 'package:h_player_flutter/utils/debounce.dart';
import 'package:h_player_flutter/widgets/pagination.dart';
import 'package:provider/provider.dart';
import 'package:loading_animations/loading_animations.dart';

import 'drawer.dart';
import 'tab_view.dart';
import '../../states/index.dart';
import 'tabs.dart';

class HomePageRoute extends StatefulWidget {
  HomePageRoute({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageRouteState createState() => _HomePageRouteState(title: title);
}

class _HomePageRouteState extends State<HomePageRoute> {
  _HomePageRouteState({this.title});

  final String title;
  HomePageState _homePageState;
  TabController _controller;

  double _paginationPos = 0;

  @override
  void initState() {
    super.initState();
    initLoad();
    getData = debounce(_debounceConfig);
    drawGetData = debounce(_debounceDrawConfig);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _controllerListener() {
    onTypeSwitch(_controller.index);

  }

  void initLoad() async {
    _homePageState = HomePageState(context);
    await _homePageState.getXmlData();
    final videoTypeState = Provider.of<VideoTypeState>(context, listen: false);
    _controller = TabController(
        length: videoTypeState.list.length, vsync: ScrollableState());
    _controller.addListener(_controllerListener);
  }

  void onDrawTap(VideoSourceType value) async {
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context, listen: false);
    final videoCardState = Provider.of<VideoCardState>(context, listen: false);
    if (videoSourceState.currentSouce.id == value.id) return;
    videoCardState.setLoading(true);

    _homePageState = HomePageState(context);
    HomePageState.toSwitchVideoSource(context, value);
    drawGetData();
  }

  void _debounceConfig() {
    final paginationState =
        Provider.of<PaginationState>(context, listen: false);
    final videoTypeState = Provider.of<VideoTypeState>(context, listen: false);
    final videoCardState = Provider.of<VideoCardState>(context, listen: false);
    videoCardState.setLoading(true);
    videoCardState.setVideoList([]);
    _homePageState.getXmlData(queryParameters: {
      'pg': paginationState.currentPage,
      't': videoTypeState.currentVideoType.id != '-9999'
          ? videoTypeState.currentVideoType.id
          : '',
    });
  }

  void _debounceDrawConfig() async {
    await _homePageState.getXmlData(queryParameters: {});

    final videoTypeState = Provider.of<VideoTypeState>(context, listen: false);
    if(_controller != null) {
      _controller.removeListener(_controllerListener);
      _controller.animateTo(0);
    }
    _controller = TabController(
        length: videoTypeState.list.length, vsync: ScrollableState());
    _controller.addListener(_controllerListener);
  }

  Function getData;
  Function drawGetData;
  void upload() async {
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context, listen: false);
    final VideoTypeState videoTypeState =
        Provider.of<VideoTypeState>(context, listen: false);
    final VideoCardState videoCardState =
        Provider.of<VideoCardState>(context, listen: false);
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    File file = File(result.files.first.path);
    final Iterable listIterable = jsonDecode(file.readAsStringSync());
    final List<VideoSourceType> list =
        List<Map<String, dynamic>>.from(listIterable)
            .map((item) => VideoSourceType.fromJson(item))
            .toList();
    videoTypeState.setList([]);
    videoCardState.setVideoList([]);
    videoCardState.setLoading(true);
    videoSourceState.setList(list);
    _controller = TabController(
        length: videoTypeState.list.length, vsync: ScrollableState());
    initLoad();
  }

  void _prevPage() {
    final paginationState =
        Provider.of<PaginationState>(context, listen: false);
    paginationState.prevPage();
    getData();
  }

  void _nextPage() {
    final paginationState =
        Provider.of<PaginationState>(context, listen: false);
    paginationState.nextPage();

    getData();
  }

  void _lastPage() {
    final paginationState =
        Provider.of<PaginationState>(context, listen: false);
    paginationState.lastPage();

    getData();
  }

  void _firstPage() {
    final paginationState =
        Provider.of<PaginationState>(context, listen: false);
    paginationState.firstPage();
    getData();
  }

  void _toPage(String page) {
    final paginationState =
        Provider.of<PaginationState>(context, listen: false);
    paginationState.setPage(int.parse(page));
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final VideoTypeState videoTypeState = Provider.of<VideoTypeState>(context);
    final PaginationState paginationState =
        Provider.of<PaginationState>(context);
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context);
    if (videoTypeState.list.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: Center(
          child: videoSourceState.sourceList.length > 0
              ? LoadingBouncingGrid.circle(
                  backgroundColor: Theme.of(context).primaryColor,
                )
              : uploadLayout(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(videoSourceState.currentSouce.name ?? title),
        // centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 16),
            child: actiondBtn(
                color: Colors.white,
                size: 20,
                icon: Icons.search,
                onPress: () {
                  Navigator.pushNamed(context, 'search');
                }),
          ),
          Container(
            padding: EdgeInsets.only(right: 16),
            child: actiondBtn(
              color: Colors.white,
              size: 20,
              icon: Icons.file_upload,
              onPress: upload,
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 16),
            child:
                actiondBtn(
                    color: Colors.white, size: 20,
                    icon: Icons.favorite,
                  onPress: () {
                    Navigator.pushNamed(context, 'collection');
                  }
                ),

          ),
        ],
        bottom: tabBar(),
      ),
      drawer: Drawer(
        child: VideoTypeList(
          onTap: (value) => onDrawTap(value),
        ),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: [
            _mainView(),
            AnimatedPositioned(
              bottom: paginationState.totalPage == 0 ? -100 : _paginationPos,
              child: Container(
                color: Colors.white,
                height: 50,
                padding: EdgeInsets.only(top: 10),
                child: PaginationControl(
                  page: paginationState.currentPage,
                  maxPage: paginationState.totalPage,
                  toNextPage: _nextPage,
                  toPrevPage: _prevPage,
                  toFirstPage: _firstPage,
                  toLastPage: _lastPage,
                  toSkipPage: _toPage,
                ),
              ),
              duration: Duration(milliseconds: 100),
            )
            // Positioned(
            //   bottom: 5,

            // ),
          ],
        ),
      ),
    );
  }

  Widget _mainView() {
    final VideoSourceState videoSourceState =
        Provider.of<VideoSourceState>(context);
    final VideoTypeState videoTypeState = Provider.of<VideoTypeState>(context);
    return videoSourceState.sourceList.length > 0
        ? TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _controller,
            children: videoTypeState.list.map((type) => HomeTabView()).toList())
        : uploadLayout();
  }

  Widget actiondBtn({
    double size = 50,
    Color color,
    IconData icon,
    Function onPress,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        color: color,
        padding: EdgeInsets.all(0),
        icon: Icon(
          icon,
          size: size,
        ),
        onPressed: onPress ?? () {},
      ),
    );
  }

  Widget uploadLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            actiondBtn(
                color: Theme.of(context).primaryColor,
                icon: Icons.file_upload,
                onPress: upload),
            Text(
              '点击上传视频源',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void onTypeSwitch(int index) async {
    final VideoTypeState videoTypeState =
    Provider.of<VideoTypeState>(context, listen: false);
    if (videoTypeState.list[index].id == videoTypeState.currentVideoType.id)
      return;
    final VideoCardState videoCardState =
    Provider.of<VideoCardState>(context, listen: false);
    videoCardState.setLoading(true);
    HomePageState.toSwitchVideoType(context, videoTypeState.list[index]);
    final homeModel = HomePageState(context);
    final Map<String, dynamic> params = {
      'pg': 1,
      't': videoTypeState.currentVideoType.id,
    };
    await Future.value([setState(() {
      _paginationPos = -100;
    })]);
    await homeModel.getXmlData(queryParameters: params);
    await Future.delayed(Duration(milliseconds: 200)).then((value) => setState(() {
      _paginationPos = 0;
    }));

  }

  Widget tabBar() {
    final VideoTypeState videoTypeState = Provider.of<VideoTypeState>(context);
    return TabBar(
      controller: _controller,
      isScrollable: true,
      tabs: videoTypeState.list.map((e) => HomeTab(tab: e)).toList(),
      // onTap: (value) => onTypeSwitch(value),
    );
  }
}
