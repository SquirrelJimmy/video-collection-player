import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:h_player_flutter/widgets/configurable_expansion_tile.dart';
import 'package:h_player_flutter/widgets/pagination.dart';
import 'package:provider/provider.dart';
import '../../widgets/video_player/player.dart';
import '../../index.dart';

class VideoDetail extends StatefulWidget {
  @override
  _VideoDetail createState() => _VideoDetail();
}

class _VideoDetail extends State<VideoDetail> {
  PlaySource playSource;
  VideoCardType videoInfo;
  PlaySourcePagination pagination;
  List<PlaySource> subList = [];

  bool showInput = false;
  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    super.initState();
    videoInfo =
        Provider.of<VideoCardState>(context, listen: false).currentVideoInfo;
    final playList = _dealPlaySource();
    final pageList = _subPlayList(playList);
    pagination = PlaySourcePagination(data: pageList);
    subList = pageList[0];
    playSource = playList[0];
  }

  @override
  void dispose() {
    super.dispose();
    // flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Offstage(
          offstage: true,
          child: AppBar(),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Container(
          margin: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top),
          color: Colors.white,
          child: SafeArea(
            child: Stack(
              children: [
                FPlayer(
                  url: playSource.source,
                  autoPlay: false,
                  title: '${videoInfo.name} ${playSource.name}',
                  poster: videoInfo.pic,
                ),
                // HVideoPlayer(
                //   url: playSource.source,
                //   poster: videoInfo.pic,
                //   title: '${videoInfo.name} ${playSource.name}',
                // ),
                Container(
                  padding: EdgeInsets.only(top: screenSize.width * 9 / 16),
                  child: ListView(
                    children: [
                      videoInfoBuild(),
                      videoPlayListBuild(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget videoInfoBuild() {
    final primaryColor = Theme.of(context).primaryColor;
    return ConfigurableExpansionTile(
      animatedWidgetFollowingHeader: Container(
        padding: EdgeInsets.only(right: 18, left: 18),
        child: Icon(
          Icons.expand_more,
          size: 20,
          color: Colors.white,
        ),
      ),
      header: Expanded(
        child: Container(
          padding: EdgeInsets.only(left: 18),
          height: 40,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(top: 4, right: 6),
                child: Icon(
                  Icons.info,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              Container(
                width: screenSize.width - 104,
                child: Text(
                  '${videoInfo.name} ${playSource.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      headerBackgroundColor: primaryColor,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text('图片: ', style: TextStyle(fontSize: 16)),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  videoInfo.pic,
                  width: 80,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: screenSize.width,
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text('演员: ${videoInfo.actor}',
                  style: TextStyle(fontSize: 16)),
            )
          ],
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5),
              child:
                  Text('地区: ${videoInfo.area}', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
        Row(children: [
          Container(
              width: screenSize.width,
              padding: EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Text('导演: ${videoInfo.director}',
                  style: TextStyle(fontSize: 16)))
        ]),
        Row(children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child:
                Text('语言: ${videoInfo.lang}', style: TextStyle(fontSize: 16)),
          )
        ]),
        Row(children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child:
                Text('时间: ${videoInfo.last}', style: TextStyle(fontSize: 16)),
          )
        ]),
        Row(children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child:
                Text('备注: ${videoInfo.note}', style: TextStyle(fontSize: 16)),
          )
        ]),
        Row(children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5),
            child:
                Text('年代: ${videoInfo.year}', style: TextStyle(fontSize: 16)),
          )
        ]),
        Row(children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child:
                Text('类型: ${videoInfo.type}', style: TextStyle(fontSize: 16)),
          )
        ]),
        Row(children: [
          Container(
            width: screenSize.width,
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child:
            Text('简介: ${videoInfo.des}', style: TextStyle(fontSize: 16)),
          )
        ]),
      ],
    );
  }

  Widget videoPlayListBuild() {
    return Container(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(10),
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '剧集分集',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite, color: Theme.of(context).primaryColor,),
                ),
              ],
            ),
          ),
          // 播放列表
          ...playListBuild(),
          // 分页操作
          paginationBuild(),
        ],
      ),
    );
  }

  List<Widget> playListBuild() {
    return [
      ...subList.map(
        (item) => Container(
          padding: EdgeInsets.only(bottom: 10),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(flex: 1, child: Text(item.name)),
              Flexible(
                flex: 1,
                child: Container(
                  child: Text(
                    item.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: PaginationControl.radiusButton(
                  context: context,
                  onTap: () {
                    Clipboard.setData(new ClipboardData(text: item.source));
                    Fluttertoast.showToast(msg: '地址已粘贴');
                  },
                  child: Icon(
                    Icons.content_copy,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: PaginationControl.radiusButton(
                  context: context,
                  child: Icon(
                    playSource.key == item.key ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 22,
                  ),
                  onTap: () {
                    if (playSource.key == item.key) return;
                    setState(() {
                      playSource = item;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget paginationBuild() {
    return PaginationControl(
      page: pagination.page,
      maxPage: pagination.total,
      toSkipPage: (value) {
        setState(() {
          subList = pagination.toSkipPage(int.parse(value));
        });
      },
      toFirstPage: () {
        setState(() {
          subList = pagination.toFirstPage();
        });
      },
      toLastPage: () {
        setState(() {
          subList = pagination.toLastPage();
        });
      },
      toNextPage: () {
        setState(() {
          subList = pagination.toNextPage();
        });
      },
      toPrevPage: () {
        setState(() {
          subList = pagination.toPrevPage();
        });
      },
    );
  }

  List<PlaySource> _dealPlaySource() {
    final String dl = videoInfo.dl.dd;
    final list = dl.split('\#').map((str) => str.split('\$')).map((l) {
      if (l.length == 1) {
        return new PlaySource(
          key: Key(l[0]),
          name: '第一集',
          source: l[0],
        );
      }

      return new PlaySource(
        key: Key(l[1]),
        name: l[0],
        source: l[1],
      );
    }).toList();
    return list;
  }

  List<List<PlaySource>> _subPlayList(List<PlaySource> playList) {
    final int size = 10;
    final List<List<PlaySource>> list = [];
    for (int i = 0; i < playList.length; i += size) {
      final List<PlaySource> sub = [];
      for (int j = 0; j < size; j++) {
        if (i + j >= playList.length) break;
        sub.add(playList[i + j]);
      }
      list.add(sub);
    }
    return list;
  }
}

class PlaySource {
  Key key;
  String name;
  String source;
  PlaySource({this.key, this.name, this.source});
}

class PlaySourcePagination {
  List<List<PlaySource>> data = [];

  int _total;
  int _page = 1;

  int get total => _total;
  int get page => _page;

  PlaySourcePagination({this.data}) {
    _total = data.length;
  }

  List<PlaySource> toNextPage() {
    if (_page >= _total) {
      _page = _total;
      return data[_total - 1];
    }
    _page++;
    return data[_page - 1];
  }

  List<PlaySource> toPrevPage() {
    if (_page <= 1) {
      _page = 1;
      return data[0];
    }
    _page--;
    return data[page - 1];
  }

  List<PlaySource> toFirstPage() {
    _page = 1;
    return data[0];
  }

  List<PlaySource> toLastPage() {
    _page = _total;
    return data[_total - 1];
  }

  List<PlaySource> toSkipPage(int page) {
    _page = page;
    return data[_page - 1];
  }
}
