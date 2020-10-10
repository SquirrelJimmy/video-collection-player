import 'dart:async';
import 'dart:math';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';


class FijkPanel2 extends StatefulWidget {
  final FijkPlayer player;
  final FijkData data;
  final VoidCallback onBack;
  final Size viewSize;
  final Rect texPos;
  final bool fill;
  final bool doubleTap;
  final bool snapShot;
  final int hideDuration;
  final String title;
  final bool isUpdateUrl;


  const FijkPanel2(
      {Key key,
      @required this.player,
      this.isUpdateUrl,
      this.title,
      this.data,
      this.fill,
      this.onBack,
      this.viewSize,
      this.hideDuration,
      this.doubleTap,
      this.snapShot,
      this.texPos})
      : assert(player != null),
        assert(
            hideDuration != null && hideDuration > 0 && hideDuration < 10000),
        super(key: key);

  @override
  __FijkPanel2State createState() => __FijkPanel2State();
}

class __FijkPanel2State extends State<FijkPanel2> {
  FijkPlayer get player => widget.player;

  Timer _hideTimer;
  Timer _hideAwardTimer;
  bool _hideStuff = true;
  bool _hideAward = true;
  bool _hideCenter = false;

  Timer _statelessTimer;
  bool _prepared = false;
  bool _playing = false;
  bool _dragLeft;
  double _volume;
  double _brightness;

  double _deltaAward = 0;
  Duration _awardDur;

  double _seekPos = -1.0;
  Duration _duration = Duration();
  Duration _currentPos = Duration();
  Duration _bufferPos = Duration();

  bool _update = false;

  String _oldUrl = '';

  StreamSubscription _currentPosSubs;
  StreamSubscription _bufferPosSubs;

  StreamController<double> _valController;

  // snapshot
  ImageProvider _imageProvider;
  Timer _snapshotTimer;

  Size get _screenSize => MediaQuery.of(context).size;

  // Is it needed to clear seek data in FijkData (widget.data)
  bool _needClearSeekData = true;
  Color get _color => Theme.of(context).primaryColor;


  static const FijkSliderColors sliderColors = FijkSliderColors(
      cursorColor: Color.fromARGB(240, 250, 100, 10),
      playedColor: Color.fromARGB(200, 240, 90, 50),
      baselineColor: Color.fromARGB(100, 20, 20, 20),
      bufferedColor: Color.fromARGB(180, 200, 200, 200));

  @override
  void initState() {
    super.initState();
    _needClearSeekData = true;
    _valController = StreamController.broadcast();
    _prepared = player.state.index >= FijkState.prepared.index;
    _playing = player.state == FijkState.started;
    _duration = player.value.duration;
    _currentPos = player.currentPos;
    _bufferPos = player.bufferPos;
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      if (_hideStuff == false) {
        setState(() {
          _currentPos = v;
        });
      } else {
        _currentPos = v;
      }
      if (_needClearSeekData) {
        widget.data.clearValue('__fijkview_panel_init_volume');
      }
      _needClearSeekData = false;
    });

    if (widget.data.contains('__fijkview_panel_sekto_position')) {
      var pos =
      widget.data.getValue('__fijkview_panel_sekto_position') as double;
      _currentPos = Duration(milliseconds: pos.toInt());
    }

    _bufferPosSubs = player.onBufferPosUpdate.listen((v) {
      if (_hideStuff == false) {
        setState(() {
          _bufferPos = v;
        });
      } else {
        _bufferPos = v;
      }
    });
    player.addListener(_playerValueChanged);
  }


  @override
  void dispose() {
    super.dispose();
    _valController?.close();
    _hideTimer?.cancel();
    _hideAwardTimer?.cancel();
    _statelessTimer?.cancel();
    _snapshotTimer?.cancel();
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    player.removeListener(_playerValueChanged);
  }

  // @override
  // void didUpdateWidget(FijkPanel2 oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   print(widget.isUpdateUrl);
  //   print(oldWidget.isUpdateUrl);
  // }
  double dura2double(Duration d) {
    return d != null ? d.inMilliseconds.toDouble() : 0.0;
  }

  void _playerValueChanged() {
    // print(_currentPos);
    FijkValue value = player.value;

    if(value.state == FijkState.idle) {
      _currentPos = Duration(microseconds: 0);
    }
    if (value.duration != _duration) {
      if (_hideStuff == false) {
        setState(() {
          _duration = value.duration;
        });
      } else {
        _duration = value.duration;
      }
    }
    bool playing = (value.state == FijkState.started);
    bool prepared = value.prepared;
    if (playing != _playing ||
        prepared != _prepared ||
        value.state == FijkState.asyncPreparing) {
      setState(() {
        _playing = playing;
        _prepared = prepared;
      });
    }
  }

  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(milliseconds: widget.hideDuration), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void onTapFun() {
    if (_hideStuff == true) {
      _restartHideTimer();
    }
    setState(() {
      _hideStuff = !_hideStuff;
    });
  }

  void playOrPause() {
    if (player.isPlayable() || player.state == FijkState.asyncPreparing) {
      if (player.state == FijkState.started) {
        player.pause();
      } else {
        player.start();
      }
    } else {
      FijkLog.w("Invalid state ${player.state} ,can't perform play or pause");
    }
  }

  void onDoubleTapFun() {
    playOrPause();
  }

  void onVerticalDragStartFun(DragStartDetails d) {
    if (d.localPosition.dx > 5 * panelWidth() / 6 &&
        d.localPosition.dx <= panelWidth()) {
      // right, volume
      _dragLeft = false;
      FijkVolume.getVol().then((v) {
        if (widget.data != null &&
            !widget.data.contains('__fijkview_panel_init_volume')) {
          widget.data.setValue('__fijkview_panel_init_volume', v);
        }
        setState(() {
          _volume = v;
          _valController.add(v);
        });
      });
    } else if (d.localPosition.dx > 0 &&
        d.localPosition.dx <= panelWidth() / 6) {
      // left, brightness
      _dragLeft = true;
      FijkPlugin.screenBrightness().then((v) {
        if (widget.data != null &&
            !widget.data.contains('__fijkview_panel_init_brightness')) {
          widget.data.setValue('__fijkview_panel_init_brightness', v);
        }
        setState(() {
          _brightness = v;
          _valController.add(v);
        });
      });
    }
    _statelessTimer?.cancel();
    _statelessTimer = Timer(const Duration(milliseconds: 2000), () {
      setState(() {});
    });
  }

  void onVerticalDragUpdateFun(DragUpdateDetails d) {
    if (d.delta.dx.abs() > 0) return;
    double delta = d.primaryDelta / panelHeight();
    delta = -delta.clamp(-1.0, 1.0);
    if (_dragLeft != null && _dragLeft == false) {
      if (_volume != null) {
        _volume += delta;
        _volume = _volume.clamp(0.0, 1.0);
        FijkVolume.setVol(_volume);
        setState(() {
          _valController.add(_volume);
        });
      }
    } else if (_dragLeft != null && _dragLeft == true) {
      if (_brightness != null) {
        _brightness += delta;
        _brightness = _brightness.clamp(0.0, 1.0);
        FijkPlugin.setScreenBrightness(_brightness);
        setState(() {
          _valController.add(_brightness);
        });
      }
    }
  }

  void onVerticalDragEndFun(DragEndDetails e) {
    _volume = null;
    _brightness = null;
  }

  void onHorizontalDragUpdateFun(DragUpdateDetails d) {
    if (d.delta.dy.abs() > 0) return;
    _hideAwardTimer?.cancel();
    final detal = d.primaryDelta.clamp(-1.0, 1.0).ceil();
    double duration = dura2double(_duration);
    double currentValue = dura2double(_currentPos);
    currentValue = currentValue.clamp(0.0, duration);
    _deltaAward += detal;
    currentValue = (currentValue + _deltaAward * 1000).clamp(0.0, duration);
    setState(() {
      _hideStuff = true;
      _hideAward = false;
      _awardDur = Duration(milliseconds: currentValue.toInt());
    });
  }

  void onHorizontalDragEndFun(DragEndDetails d) {
    double v = dura2double(_awardDur);
    setState(() {
      player.seekTo(v.toInt());
      _currentPos = Duration(milliseconds: v.toInt());
      widget.data.setValue('__fijkview_panel_sekto_position', v);
      // _needClearSeekData = true;
    });
    _deltaAward = 0;
    _hideAwardTimer = Timer(Duration(milliseconds: 1000), () {
      setState(() {
        _hideAward = true;
      });
    });
  }

  String _duration2String(Duration duration) {
    if (duration.inMilliseconds < 0) return "-: negtive";

    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    int inHours = duration.inHours;
    return inHours > 0
        ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
        : "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget buildPlayButton(BuildContext context, double height) {
    Icon icon = (player.state == FijkState.started)
        ? Icon(Icons.pause)
        : Icon(Icons.play_arrow);
    bool fullScreen = player.value.fullScreen;
    return IconButton(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(0),
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: playOrPause,
    );
  }

  Widget buildFullScreenButton(BuildContext context, double height) {
    Icon icon = player.value.fullScreen
        ? Icon(Icons.fullscreen_exit)
        : Icon(Icons.fullscreen);
    bool fullScreen = player.value.fullScreen;
    return IconButton(
      padding: EdgeInsets.all(0),
      alignment: Alignment.bottomCenter,
      iconSize: fullScreen ? height : height * 0.8,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: () {
        player.value.fullScreen
            ? player.exitFullScreen()
            : player.enterFullScreen();
      },
    );
  }

  Widget buildTimeText(BuildContext context, double height) {
    String text =
        "${_duration2String(_currentPos)}" + "/${_duration2String(_duration)}";
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 14),
      child:
          Text(text, style: TextStyle(fontSize: 12, color: Color(0xFFFFFFFF))),
    );
  }

  Widget buildSlider(BuildContext context) {
    double duration = dura2double(_duration);

    double currentValue = _seekPos > 0 ? _seekPos : dura2double(_currentPos );
    currentValue = currentValue.clamp(0.0, duration);
    double bufferPos = dura2double(_bufferPos);
    bufferPos = bufferPos.clamp(0.0, duration);

    return Container(
      height: 30,
      // color: Colors.red,
      padding: EdgeInsets.only(left: 16, right: 34),
      child: FijkSlider(
        colors: sliderColors,
        value: currentValue,
        cacheValue: bufferPos,
        min: 0.0,
        max: duration,
        onChanged: (v) {
          _restartHideTimer();
          setState(() {
            _currentPos = Duration(milliseconds: v.round());
            _seekPos = v;
          });
        },
        onChangeEnd: (v) {
          setState(() {
            player.seekTo(v.toInt());
            _currentPos = Duration(milliseconds: _seekPos.toInt());
            widget.data.setValue('__fijkview_panel_sekto_position', _seekPos);
            // _needClearSeekData = true;
            _seekPos = -1.0;
          });
        },
      ),
    );
  }

  Widget buildBottom(BuildContext context, double height) {
    if (_duration != null && _duration.inMilliseconds > 0) {
      return Row(
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          buildPlayButton(context, height),
          buildTimeText(context, height),
          Expanded(child: Container()),
          buildFullScreenButton(context, height),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildPlayButton(context, height),
          Expanded(child: Container()),
          buildFullScreenButton(context, height),
        ],
      );
    }
  }

  void takeSnapshot() {
    player.takeSnapShot().then((v) {
      var provider = MemoryImage(v);
      precacheImage(provider, context).then((_) {
        setState(() {
          _imageProvider = provider;
        });
      });
      FijkLog.d("get snapshot succeed");
    }).catchError((e) {
      FijkLog.d("get snapshot failed");
    });
  }

  Widget buildPanel(BuildContext context) {
    double height = panelHeight();

    bool fullScreen = player.value.fullScreen;
    Widget centerWidget = Container(
      color: Color(0x00000000),
    );

    Widget centerChild = Container(
      color: Color(0x00000000),
    );

    if (fullScreen && widget.snapShot) {
      centerWidget = centerWidget = Row(
        children: <Widget>[
          Expanded(child: centerChild),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(0),
                  color: Color(0xFFFFFFFF),
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    takeSnapshot();
                  },
                ),
              ],
            ),
          )
        ],
      );
    }
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      // mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: height > 80 ? 50 : height / 5,
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88000000), Color(0x00000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              player.value.fullScreen ? buildBack(context) : Text(''),
              Expanded(
                child: Container(
                  // alignment: Alignment.center,
                  padding: EdgeInsets.only(bottom: 2, left: player.value.fullScreen ? 0 : 46),
                  child: Text(
                    widget.title ?? '',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(child: centerWidget),
        Container(
          height: height > 80 ? 80 : height / 2,
          // color: Colors.green,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x88000000), Color(0x00000000)],
              end: Alignment.topCenter,
              begin: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            // height: height > 80 ? 44 : height / 2,
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Stack(
              children: [
                Positioned(
                  bottom: 30,
                  // height: height > 80 ? 44 : height / 2,
                  child: Container(
                    // color: _color,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(right: 20),
                    width: _screenSize.width,
                    child: buildBottom(context, height > 80 ? 40 : height / 2),
                  ),
                ),
                player.isPlayable() || player.state == FijkState.prepared ? Positioned(
                  bottom: 0,
                  child: Container(
                    width: _screenSize.width,
                    child: buildSlider(context),
                  ),
                ): Container(),
              ],
            ),
          ),
        )

      ],
    );
  }

  GestureDetector buildGestureDetector(BuildContext context) {
    return GestureDetector(
      onTap: onTapFun,
      onDoubleTap: widget.doubleTap ? onDoubleTapFun : null,
      onVerticalDragUpdate: onVerticalDragUpdateFun,
      onVerticalDragStart: onVerticalDragStartFun,
      onVerticalDragEnd: onVerticalDragEndFun,
      onHorizontalDragEnd: onHorizontalDragEndFun,
      onHorizontalDragUpdate: onHorizontalDragUpdateFun,
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: _hideAward,
            child: AnimatedOpacity(
              opacity: _hideAward ? 0 : 1,
              duration: Duration(milliseconds: 300),
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                  decoration: BoxDecoration(
                      color: Color(0x88000000),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Text(
                    '${_duration2String(_awardDur ?? _currentPos)}',
                    style: TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ),
          ),
          AbsorbPointer(
            absorbing: _hideStuff,
            child: AnimatedOpacity(
              opacity: _hideStuff ? 0 : 1,
              duration: Duration(milliseconds: 300),
              child: buildPanel(context),
            ),
          ),
          player.isPlayable() ? Offstage(
            offstage: player.state == FijkState.started,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: player.state == FijkState.started ? 0 : 1,
              child: Center(
                child: RawMaterialButton(
                  onPressed: playOrPause,
                  elevation: 2.0,
                  fillColor: Color(0x88000000),
                  child: Icon(
                    player.state == FijkState.started ? Icons.pause : Icons.play_arrow,
                    size: 42.0,
                    color: Color(0xFFFFFFFF),
                  ),
                  padding: EdgeInsets.all(6.0),
                  shape: CircleBorder(),
                ),
              ),
            )
          ) : Text(''),
          player.isBuffering ? Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(_color)),
            ),
          ) : Text(''),
          player.value.fullScreen ? Text('') : Positioned(
            top: -11,
            child: buildBack(context),
          ),
        ],
      ),
    );
  }

  Rect panelRect() {
    Rect rect = player.value.fullScreen || (true == widget.fill)
        ? Rect.fromLTWH(0, 0, widget.viewSize.width, widget.viewSize.height)
        : Rect.fromLTRB(
            max(0.0, widget.texPos.left),
            max(0.0, widget.texPos.top),
            min(widget.viewSize.width, widget.texPos.right),
            min(widget.viewSize.height, widget.texPos.bottom));
    return rect;
  }

  double panelHeight() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.height;
    } else {
      return min(widget.viewSize.height, widget.texPos.bottom) -
          max(0.0, widget.texPos.top);
    }
  }

  double panelWidth() {
    if (player.value.fullScreen || (true == widget.fill)) {
      return widget.viewSize.width;
    } else {
      return min(widget.viewSize.width, widget.texPos.right) -
          max(0.0, widget.texPos.left);
    }
  }

  Widget buildBack(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.only(left: 5),
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xDDFFFFFF),
      ),
      onPressed: () {
        player.value.fullScreen
            ? player.exitFullScreen()
            : Navigator.pop(context);
      },
    );
  }

  Widget buildStateless() {
    if (_volume != null || _brightness != null) {
      Widget toast = _volume == null
          ? defaultFijkBrightnessToast(_brightness, _valController.stream)
          : defaultFijkVolumeToast(_volume, _valController.stream);
      return IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: Duration(milliseconds: 500),
          child: toast,
        ),
      );
    } else if (player.state == FijkState.asyncPreparing) {
      return Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_color)),
        ),
      );
    } else if (player.state == FijkState.error) {
      return Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.error,
          size: 30,
          color: Color(0x99FFFFFF),
        ),
      );
    } else if (_imageProvider != null) {
      _snapshotTimer?.cancel();
      _snapshotTimer = Timer(Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _imageProvider = null;
          });
        }
      });
      return Center(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.yellowAccent, width: 3)),
            child: Image(
                height: MediaQuery.of(context).size.width * 9 / 16,
                fit: BoxFit.contain,
                image: _imageProvider),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Rect rect = panelRect();

    List ws = <Widget>[];

    if (_statelessTimer != null && _statelessTimer.isActive) {
      ws.add(buildStateless());
    } else if (player.state == FijkState.asyncPreparing) {
      ws.add(buildStateless());
    } else if (player.state == FijkState.error) {
      ws.add(buildStateless());
    } else if (_imageProvider != null) {
      ws.add(buildStateless());
    }
    ws.add(buildGestureDetector(context));
    // ws.add();
    return Positioned.fromRect(
      rect: rect,
      child: Stack(children: ws),
    );
  }
}

