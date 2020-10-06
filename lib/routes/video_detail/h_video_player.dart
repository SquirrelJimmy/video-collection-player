import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'ui.dart';

class HVideoPlayer extends StatefulWidget {
  final String url;
  final String poster;
  final String title;
  final bool autoPlay;

  HVideoPlayer({Key key, @required this.url, this.poster, this.title, this.autoPlay = false});
  @override
  _HVideoPlayer createState() => _HVideoPlayer();
}

class _HVideoPlayer extends State<HVideoPlayer> with WidgetsBindingObserver {
  Size get screenSize => MediaQuery.of(context).size;
  FijkPlayer player = FijkPlayer();
  bool isUpdateUrl = false;
  bool _setUpdate = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FijkLog.setLevel(FijkLogLevel.Silent);
    FijkVolume.setUIMode(0);
    startPlay(widget.autoPlay);
    // player.addListener(_playerListen);
  }

  // void _playerListen() {
  //   FijkValue value = player.value;
  //   if(_setUpdate && value.state == FijkState.paused) {
  //     _setUpdate = false;
  //     setState(() {
  //       isUpdateUrl = false;
  //     });
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        // if (player.isPlayable()) {
        //   player
        // }
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        if (player.isPlayable() || player.state == FijkState.asyncPreparing) {
          player.pause();
        }
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
  }

  void startPlay(bool autoPlay) async {
    await player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
    await player.setOption(FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
    await player.setOption(FijkOption.hostCategory, "request-audio-focus", 1);
    await player
        .setDataSource(widget.url, autoPlay: autoPlay, showCover: true)
        .catchError((e) {
      print("setDataSource error: $e");
    });
  }
  // void onUpdateUrl() {
  //   setState(() {
  //     isUpdateUrl = true;
  //     reset();
  //   });
  // }

  void reset() async {
    await player.stop();
    await player.reset();
    // player = FijkPlayer();
    await player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
    await player.setOption(FijkOption.playerCategory, "mediacodec-all-videos", 1);
    await player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
    await player.setOption(FijkOption.hostCategory, "request-audio-focus", 1);
    await player.setOption(FijkOption.playerCategory, 'seek-at-start', 1);
    await player.setDataSource(widget.url, autoPlay: true, showCover: true).catchError((e) {
      print("setDataSource error: $e");
    });
    await player.prepareAsync();

    await player.setOption(FijkOption.playerCategory, "start-on-prepared", 1);
  }

  @override
  void didUpdateWidget(HVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != null && widget.url != oldWidget.url) {
      reset();
      // _setUpdate = true;
      // setState(() {
      //   isUpdateUrl = true;
      // });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    player.release();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width,
      height: screenSize.width * 9 / 16,
      color: Colors.black,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: FijkView(
        player: player,
        cover: NetworkImage(widget.poster),
        width: screenSize.width,
        color: Colors.black,
        panelBuilder: (player, data, context, viewSize, texturePos) {
          return FijkPanel2(
            key: Key(widget.url),
            isUpdateUrl: isUpdateUrl,
            title: widget.title,
            player: player,
            data: data,
            viewSize: viewSize,
            texPos: texturePos,
            fill: true,
            doubleTap: true,
            snapShot: true,
            hideDuration: 4000,

          );
        },
        // fsFit: FijkFit.fill,
        // fit: FijkFit.fitWidth,
      ),
    );
  }
}
