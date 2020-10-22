

import 'dart:async';
import 'dart:developer';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:screen/screen.dart';
import 'package:volume/volume.dart';
import 'package:flutter/services.dart';


class FPlayer extends StatefulWidget {

  FPlayer({
      Key key,
      this.url,
      this.poster,
      this.autoPlay = true,
      this.title,
  });
  final String url;
  final String poster;
  bool autoPlay;
  final String title;
  @override
  _FPlayerState createState() => _FPlayerState();
}



class _FPlayerState extends State<FPlayer> {

  VideoPlayerController _controller;
  Size get _size => MediaQuery.of(context).size;
  Color get _color => Theme.of(context).primaryColor;
  bool get _isFullScreen =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  int get _duration => _controller.value.duration?.inMilliseconds ?? 0;
  int get _position => _controller.value.position?.inMilliseconds ?? 0;
  double get _onePthree => 1/3 * _size.width;
  double get _twoPthree => 2/3 * _size.width;
  double get _threePthree  =>  _size.width;

  bool _is2x = false;
  bool _is3x = false;
  bool _is5x = false;


  bool _hideStuff = true;
  bool _ctrlStuff = true;
  bool _hidePlayStuff = true;
  Timer _hideTimer;
  Timer _ctrlTimer;
  bool _isBuffering = true;
  double _progressValue;
  String _labelProgress;
  double _cacheValue = 0.0;
  double _brightness;
  double _volume;
  String _ctrlText = '';
  int _deltaAward = 0;
  bool _dragLeft;
  bool _isError = false;



  int _initialVol;

  @override
  void initState() {
    Screen.keepOn(true);
    _start();
    _controller.setVolume(1);
    _progressValue = 0.0;
    _labelProgress = '00:00';
    initAudioStreamType();
    super.initState();
  }

  Future<void> initAudioStreamType() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
    _initialVol = await Volume.getVol;
  }

  void _videoListener() {
    if(!_controller.value.initialized) return;

    if( _controller.value.isBuffering && _isBuffering == false) {
       setState(() {
         _isBuffering = true;
       });
     } else if(!_controller.value.isBuffering && _isBuffering == true) {
       setState(() {
         _isBuffering = false;
       });
     }

     if( _controller.value.hasError) {
       setState(() {
         _isBuffering = false;
         _isError = true;
       });
     }

     if(!_hideStuff && _controller.value.isPlaying) {
       _setPos();
     }

     if(!_controller.value.isPlaying) {
       _setPos();
     }

     if(_hidePlayStuff == false && _controller.value.isPlaying) {
       setState(() {
         _hidePlayStuff = true;
       });
     }

     // if(!_controller.value.isPlaying && _hidePlayStuff) {
     //   setState(() {
     //     _hidePlayStuff = false;
     //   });
     // }
  }

  _start() async {
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(_videoListener);
    await _controller.initialize();

    if(widget.autoPlay) {
      await _controller.play();
    }
    // await _controller.setVolume(10);
    setState(() {
      _hidePlayStuff = false;
    });
  }

  _setPos() {
    if(!_controller.value.initialized) return;
    int duration = _controller.value.duration.inMilliseconds;
    int position = _controller.value.position.inMilliseconds;
    int cache = _controller.value.buffered[0] != null ? _controller.value.buffered[0].end.inMilliseconds : 0;
    print(duration);
    if(position >= duration){
      position = duration;
    }
    double value = position / duration * 100;
    setState(() {
      _cacheValue =  cache / duration * 100;
      _progressValue = value;
      _labelProgress = _init2String(Duration(
        milliseconds: (value / 100 * duration).toInt()
      ));
    });
  }

  String _init2String(Duration duration) {
    if (duration == null || duration.inMilliseconds < 0) return "-: negtive";

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



  void onVerticalDragUpdateFun(DragUpdateDetails d) async {
    if(!_controller.value.initialized) return;
    if (d.delta.dx.abs() > 0) return;
    double delta = d.primaryDelta / _size.width * 9 / 16;
    delta = -delta.clamp(-1.0, 1.0);
    if (_dragLeft != null && _dragLeft == false && Volume != null) {
      if(_volume != null) {
        // double delta = d.primaryDelta /  _size.width * 9 / 16;
        // delta = -delta.clamp(-1.0, 1.0);
        _volume +=  delta * 15;
        _volume = _volume.clamp(0.0, 15.0);

        await Volume.setVol(_volume.toInt(), showVolumeUI: ShowVolumeUI.HIDE);
        // int vol = await Volume.getVol;
        setState(() {
          _ctrlText = '音量: ${(_volume / 15 * 100).toInt()}%';
          if(!_controller.value.isPlaying) {
            _hidePlayStuff = true;
          }
        });

      }

    } else if (_dragLeft != null && _dragLeft == true) {
      if (_brightness != null) {

        _brightness += delta;
        _brightness = _brightness.clamp(0.0, 1.0);
        // log(_brightness.toString());

        Screen.setBrightness(_brightness);
        setState(() {
          _ctrlText = '亮度: ${(_brightness * 100).toInt()}%';
          if(!_controller.value.isPlaying) {
            _hidePlayStuff = true;
          }
        });
      }
    }
  }

  void onVerticalDragStartFun(DragStartDetails d) async {
    if(!_controller.value.initialized) return;
    if (d.localPosition.dx > 5 * _size.width / 6 &&
        d.localPosition.dx <= _size.width) {
      // right, volume
      _dragLeft = false;
      _volume = (await Volume.getVol).toDouble();

    } else if (d.localPosition.dx > 0 &&
        d.localPosition.dx <=  _size.width / 6) {
      _dragLeft = true;
      _brightness = await Screen.brightness;
    }
    setState(() {
      _ctrlStuff = false;
    });

  }

  void onVerticalDragEndFun(DragEndDetails e) {
    _dragLeft = null;
    setState(() {
      _ctrlStuff = true;
      if(!_controller.value.isPlaying) {
        _hidePlayStuff = false;
      }
    });
  }

  void onHorizontalDragStartFun(DragStartDetails d) {
    if(!_controller.value.initialized) return;
    _ctrlTimer?.cancel();
    _deltaAward = _controller.value.position.inMilliseconds;
    setState(() {
      _ctrlStuff = false;
    });
  }

  void onHorizontalDragUpdateFun(DragUpdateDetails d) {
    if(!_controller.value.initialized) return;
    if (d.delta.dy.abs() > 0) return;
    final detal = d.primaryDelta.clamp(-1.0, 1.0) * 1000;
    _deltaAward +=  detal.toInt();

    _deltaAward = _deltaAward.clamp(0, _duration);

    final String str = _init2String(Duration(
        milliseconds: _deltaAward
    ));
    setState(() {
      _ctrlText = '$str/${_init2String(Duration(
          milliseconds: _duration
      ))}';
      if(!_controller.value.isPlaying) {
        _hidePlayStuff = true;
      }
    });
  }


  void onHorizontalDragEndFun(DragEndDetails d) {
    if(!_controller.value.initialized) return;
    _ctrlTimer = Timer(Duration(milliseconds: 1000), () {
      setState(() {
        _ctrlStuff = true;
        if(!_controller.value.isPlaying) {
          _hidePlayStuff = false;
        }
      });
    });
    _controller.seekTo(Duration(milliseconds: _deltaAward));
  }

  void onLongPressStartFun(LongPressStartDetails d) {
    if(!_controller.value.initialized && !_controller.value.isPlaying) return;
    _ctrlTimer?.cancel();
    // final dx = d.localPosition.dx;
    // if(dx >= 0 && dx < _onePthree) {
    //   _is3x = true;
    // } else if(dx < _twoPthree && dx >= _onePthree ) {
    //   _is2x = true;
    // } else {
    //   _is5x = true;
    // }
    setState(() {
      _ctrlStuff = false;
      _ctrlText = '>> x2 >>';
    });
  }

  void onLongPressFun() {
    if(!_controller.value.initialized && !_controller.value.isPlaying) return;
    // if(_is2x) {
    //   _controller.setPlaybackSpeed(2.0);
    // } else if(_is3x) {
    //   _controller.setPlaybackSpeed(3.0);
    // } else if(_is5x) {
    //   _controller.setPlaybackSpeed(5.0);
    // }
    _controller.setPlaybackSpeed(2.0);
  }

  void onLongPressEndFun(LongPressEndDetails d) async {
    if(!_controller.value.initialized && !_controller.value.isPlaying) return;
    _controller.setPlaybackSpeed(1.0);
    // _is3x = false;
    // _is2x = false;
    // _is5x = false;
    await _controller.pause();
    await _controller.play();
    _ctrlTimer = Timer(Duration(milliseconds: 200), () {
      setState(() {
        _ctrlStuff = true;
        _ctrlText = '';
      });
    });
  }

  void _initVideo() {
    _hideTimer?.cancel();
    _ctrlTimer?.cancel();

    _hideStuff = true;
    _ctrlStuff = true;
    _hidePlayStuff = true;
    _hideTimer = null;
    _ctrlTimer = null;
    _isBuffering = true;
    _progressValue = null;
    _labelProgress = null;
    _isError = false;
    _cacheValue = 0.0;
    _brightness = null;
    _volume = null;
    _ctrlText = '';
    _deltaAward = 0;
    _dragLeft = null;
    if(_controller != null) {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    }
    _start();
  }

  @override
  void didUpdateWidget(covariant FPlayer oldWidget) {
    if(oldWidget.url != widget.url) {
      widget.autoPlay = true;
      _initVideo();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    Screen.keepOn(false);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    Volume.setVol(_initialVol, showVolumeUI: ShowVolumeUI.HIDE);
    _hideTimer?.cancel();
    _ctrlTimer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapFun,
      onDoubleTap: _togglePlay,
      onVerticalDragUpdate: onVerticalDragUpdateFun,
      onVerticalDragStart: onVerticalDragStartFun,
      onVerticalDragEnd: onVerticalDragEndFun,
      onHorizontalDragEnd: onHorizontalDragEndFun,
      onHorizontalDragUpdate: onHorizontalDragUpdateFun,
      onHorizontalDragStart: onHorizontalDragStartFun,
      onLongPressStart: onLongPressStartFun,
      onLongPress: onLongPressFun,
      onLongPressEnd: onLongPressEndFun,
      child: WillPopScope(
        child: Container(
          color: Color(0xFF000000),
          width: _size.width,
          height: _size.width / 16 * 9,
          child: Stack(
            children: [
              Center(
                child: _controller.value.initialized && !_isError ?  AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(
                      _controller
                  ),
                ) : Container(
                  child:  Stack(
                    children: [
                      Center(child: widget.poster != null ? Image.network(widget.poster) : Container(),),
                      Center(child: _isError ? Icon(Icons.error_rounded, size: 40, color: _color,) : Container(),),

                    ],
                  ),
                ),
              ),
              Offstage(
                offstage: !_isBuffering,
                child: AnimatedOpacity(
                  opacity: _isBuffering ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(_color)),
                    ),
                  ),
                ),
              ),
              AbsorbPointer(
                absorbing: _ctrlStuff,
                child: AnimatedOpacity(
                  opacity: _ctrlStuff ? 0 : 1,
                  duration: Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      padding:
                      EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                      decoration: BoxDecoration(
                          color: Color(0x88000000),
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Text(
                        _ctrlText,
                        style: TextStyle(color: Color(0xFFFFFFFF)),
                      ),
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: _hideStuff,
                child: AnimatedOpacity(
                  opacity: _hideStuff ? 0 : 1,
                  duration: Duration(milliseconds: 300),
                  child: _buildPanel(),
                ),
              ),
              Offstage(
                offstage: _hidePlayStuff || _isError,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: _hidePlayStuff ? 0 : 1,
                  child: Center(
                    child: RawMaterialButton(
                      onPressed: _togglePlay,
                      elevation: 2.0,
                      fillColor: Color(0x88000000),
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 42.0,
                        color: Color(0xFFFFFFFF),
                      ),
                      padding: EdgeInsets.all(6.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                child: IconButton(
                  padding: EdgeInsets.only(left: 15, bottom: 3),
                  alignment: Alignment.centerLeft,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xDDFFFFFF),
                    size: 20,
                  ),
                  onPressed: () {
                    _isFullScreen
                        ? _toggleFullScreen()
                        : Navigator.pop(context);
                  },
                ),
              ),

            ],
          ),
        ),
        onWillPop: () async {
          if (_isFullScreen) {
            _toggleFullScreen();
            return false;
          }
          return true;
        },
      ),
    );
  }

  Widget _buildPanel() {
    return Column(
      children: [
        Container(
          height: 50,
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x66000000), Color(0x00000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: 5, left: 35),
            child: Text(
              widget.title ?? '',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Expanded(
          child: Container(),
        ),
        Container(
          height: _isFullScreen ? 80 : 50,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(left: 5, right: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x00000000), Color(0x66000000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
             Row(
               children: [
                Expanded(
                    child: GestureDetector(
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: _isFullScreen ? 10 : 0),
                        child: _buildSlider(),
                      ),
                    ),
                ),
               ],
             ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      padding: EdgeInsets.only(left: 5, right: 5),
                      margin: EdgeInsets.only(right: 10),
                      alignment: Alignment.centerLeft,
                      child: buildPlayButton(),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _labelProgress != null ? '$_labelProgress/${_init2String(Duration(
                            milliseconds: _duration
                        ))}' : '',
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(right:  _isFullScreen ? 15 : 5),
                        alignment: Alignment.centerRight,
                        child: buildScreenButton(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {

    return Stack(
      children: [
        SliderTheme(
          //自定义风格
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            trackShape: RoundSliderTrackShape(radius: 2),
            activeTrackColor: Colors.grey,
            thumbColor:  Colors.grey,
            //进度条滑块左边颜色
            inactiveTrackColor: Color(0xFFFFFFFF),
            overlayShape: RoundSliderOverlayShape(
              //可继承SliderComponentShape自定义形状
              overlayRadius: 10, //滑块外圈大小
            ),
            thumbShape: RoundSliderThumbShape(
              //可继承SliderComponentShape自定义形状
              disabledThumbRadius: 0, //禁用是滑块大小
              enabledThumbRadius: 0, //滑块大小
            ),
          ),
          child: Slider(
            value: _cacheValue ?? 0,
            divisions: 1000,
            onChangeEnd: _onChangeEnd,
            onChanged: _onChanged,
            min: 0,
            max: 100,
          ),
        ),
        SliderTheme(
          //自定义风格
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            // disabledInactiveTrackColor:  Colors.red,
            // activeTrackColor: Colors.red,
            //进度条滑块左边颜色
            inactiveTrackColor: Color(0x00FFFFFF),
            overlayShape: RoundSliderOverlayShape(
              //可继承SliderComponentShape自定义形状
              overlayRadius: 10, //滑块外圈大小
            ),
            thumbShape: RoundSliderThumbShape(
              //可继承SliderComponentShape自定义形状
              disabledThumbRadius: 5, //禁用是滑块大小
              enabledThumbRadius: 5, //滑块大小
            ),
            thumbColor:  Color(0xFFFFFFFF),
          ),
          child: Slider(
            value: _progressValue ?? 0,
            // label: _labelProgress ?? '',
            divisions: 1000,
            onChangeEnd: _onChangeEnd,
            onChanged: _onChanged,
            min: 0,
            max: 100,
          ),
        ),
      ],
    );
  }

  Widget buildPlayButton() {
    Icon icon = _controller.value.isPlaying
        ? Icon(Icons.pause)
        : Icon(Icons.play_arrow);
    // bool fullScreen = player.value.fullScreen;
    return IconButton(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(0),
      iconSize:  _isFullScreen ? 30 : 24,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: _togglePlay,
    );
  }

  Widget buildScreenButton() {
    Icon icon = _isFullScreen
        ? Icon(Icons.fullscreen_exit)
        : Icon(Icons.fullscreen);
    // bool fullScreen = player.value.fullScreen;
    return IconButton(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.all(0),
      iconSize: _isFullScreen ? 30 : 24,
      color: Color(0xFFFFFFFF),
      icon: icon,
      onPressed: _toggleFullScreen,
    );
  }

  void _onChangeEnd(_) {
    if (!_controller.value.initialized) {
      return;
    }
    int duration = _controller.value.duration.inMilliseconds;
    _controller.seekTo(
      Duration(milliseconds: (_progressValue / 100 * duration).toInt()),
    );
    if(!_controller.value.isPlaying) {
      _controller.play();
    }

  }

  void _onChanged(double value) {
    if (!_controller.value.initialized) {
      return;
    }
    _restartHideTimer();
    int duration = _controller.value.duration.inMilliseconds;
    setState(() {
      _progressValue = value;
      _labelProgress = _init2String(
          Duration(milliseconds: (value / 100 * duration).toInt())
      );
    });

  }


  void _restartHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(milliseconds: 4000), () {
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

  void _togglePlay() async {
   if(_position == _duration && _position != 0 && ! _controller.value.isPlaying) {
     await _controller.seekTo(Duration(milliseconds: 0));
     await _controller.play();
   } else {
     _controller.value.isPlaying ?  _controller.pause() :  _controller.play();
   }
    setState(() {
      _hidePlayStuff = !_hidePlayStuff;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      if (_isFullScreen) {
        /// 如果是全屏就切换竖屏
        AutoOrientation.portraitAutoMode();

        ///显示状态栏，与底部虚拟操作按钮
        SystemChrome.setEnabledSystemUIOverlays(
            [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      } else {
        AutoOrientation.landscapeAutoMode();

        ///关闭状态栏，与底部虚拟操作按钮
        SystemChrome.setEnabledSystemUIOverlays([]);
      }
      // _startPlayControlTimer(); // 操作完控件开始计时隐藏
    });
  }
}



class RoundSliderTrackShape extends SliderTrackShape {

  const RoundSliderTrackShape({this.disabledThumbGapWidth = 2.0, this.radius = 0});

  final double disabledThumbGapWidth;
  final double radius;

  @override
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled,
    bool isDiscrete,
  }) {
    final double overlayWidth = sliderTheme.overlayShape.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;

    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        RenderBox parentBox,
        SliderThemeData sliderTheme,
        Animation<double> enableAnimation,
        TextDirection textDirection,
        Offset thumbCenter,
        bool isDiscrete,
        bool isEnabled,
      }) {
    if (sliderTheme.trackHeight == 0) {
      return;
    }

    final ColorTween activeTrackColorTween =
    ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
    ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    double horizontalAdjustment = 0.0;
    if (!isEnabled) {
      final double disabledThumbRadius =
          sliderTheme.thumbShape.getPreferredSize(false, isDiscrete).width / 2.0;
      final double gap = disabledThumbGapWidth * (1.0 - enableAnimation.value);
      horizontalAdjustment = disabledThumbRadius + gap;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    //进度条两头圆角
    final RRect leftTrackSegment = RRect.fromLTRBR(trackRect.left, trackRect.top,
        thumbCenter.dx - horizontalAdjustment, trackRect.bottom, Radius.circular(radius));
    context.canvas.drawRRect(leftTrackSegment, leftTrackPaint);
    final RRect rightTrackSegment = RRect.fromLTRBR(thumbCenter.dx + horizontalAdjustment, trackRect.top,
        trackRect.right, trackRect.bottom, Radius.circular(radius));
    context.canvas.drawRRect(rightTrackSegment, rightTrackPaint);
  }
}


