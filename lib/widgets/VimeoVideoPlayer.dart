import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "dart:collection";

class VimeoVideoPlayer extends StatefulWidget {
  final String id;
  final StreamSink? valueListener;
  final VideoPlayerController? controller;
  final ValueNotifier<bool>? isFullscreen;
  final bool? autoPlay;
  final Function? onVideoClosed;

  VimeoVideoPlayer({
    required this.id,
    Key? key,
    this.valueListener, this.controller, this.autoPlay:false, this.isFullscreen, this.onVideoClosed
  }) : super(key: key);

  @override
  _VimeoVideoPlayerState createState() => _VimeoVideoPlayerState(id);
}

class _VimeoVideoPlayerState extends State<VimeoVideoPlayer> {
  String _id;
  bool? _overlay = true;
  Duration? _position;

  _VimeoVideoPlayerState(this._id);

  VideoPlayerController? _controller; //Custom controller
  Future<void>? initFuture;

  late QualityLinks _quality; // Quality Class
  Map? _qualityValues;
  bool _seek = false;

  double videoHeight = 0;
  double videoWidth = 0;
  double videoMargin = 0;
  bool _isFullscreen = false;
  @override
  void initState() {
    _quality = QualityLinks(_id); //Create class
    _quality.getQualitiesSync().then((value) {
      _qualityValues = value;
      _controller = widget.controller??VideoPlayerController.network(value[value.lastKey()]);
      _controller!.setLooping(true);
      if (widget.autoPlay!) _controller!.play();
      initFuture = _controller!.initialize();
      _controller!..addListener(() {
        widget.valueListener?.add(_controller!.value);
      });
      setState(() {});
    });
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isFullscreen?Colors.black:null,
      height: _isFullscreen?MediaQuery.of(context).size.height:null,
      width: _isFullscreen?MediaQuery.of(context).size.width:null,
      child: Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              GestureDetector(
                child: FutureBuilder(
                    future: initFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        //Управление шириной и высотой видео
                        double delta = MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.height *
                                _controller!.value.aspectRatio;
                        if (MediaQuery.of(context).orientation ==
                            Orientation.portrait ||
                            delta < 0) {
                          videoHeight = MediaQuery.of(context).size.width /
                              _controller!.value.aspectRatio;
                          videoWidth = MediaQuery.of(context).size.width;
                          videoMargin = 0;
                        } else {
                          videoHeight = MediaQuery.of(context).size.height - 36;
                          videoWidth = videoHeight * _controller!.value.aspectRatio;
                          videoMargin =
                              (MediaQuery.of(context).size.width - videoWidth) / 2;
                        }

                        if (_seek && _controller!.value.duration.inSeconds > 2) {
                          _controller!.seekTo(_position!);
                          _seek = false;
                        }

                        //Отрисовка элементов плеера
                        return Stack(
                          children: <Widget>[
                            Container(
                              height: videoHeight,
                              width: videoWidth,
                              margin: EdgeInsets.only(left: videoMargin),
                              child: VideoPlayer(_controller!),
                            ),
                            _videoOverlay(),
                          ],
                        );
                      } else {
                        return Center(
                            heightFactor: 6,
                            child:const CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF22A3D2)),
                            ));
                      }
                    }),
                onTap: () {
                  setState(() {
                    _overlay = !_overlay!;
                  });
                },
              )
            ],
          )),
    );
  }

  //================================ Quality ================================//
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          final children = <Widget>[];
          _qualityValues!.forEach((elem, value) => (children.add(new ListTile(
              title: new Text(" ${elem.toString()} fps"),
              onTap: () => {
                //Обновление состояние приложения и перерисовка
                setState(() {
                  _controller!.pause();
                  _controller = VideoPlayerController.network(value);
                  _controller!.setLooping(true);
                  _seek = true;
                  initFuture = _controller!.initialize();
                  _controller!.play();
                }),
              }))));

          return Wrap(
            children: children,
          );
        });
  }

  //================================ OVERLAY ================================//
  Widget _videoOverlay() {
    return _overlay!
        ? Stack(
      children: <Widget>[
        GestureDetector(
          child: Center(
            child: Container(
              width: videoWidth,
              height: videoHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    const Color(0x662F2C47),
                    const Color(0x662F2C47)
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: IconButton(
              padding: EdgeInsets.only(
                  top: videoHeight / 2 - 30,
                  bottom: videoHeight / 2 - 30),
              icon: _controller!.value.isPlaying
                  ?const Icon(Icons.pause, size: 60.0)
                  :const Icon(Icons.play_arrow, size: 60.0),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              }),
        ),
        Container(
          margin: EdgeInsets.only(
              top: videoHeight - 70, left: videoWidth + videoMargin - 50),
          child: IconButton(
              alignment: AlignmentDirectional.center,
              icon:const Icon(Icons.fullscreen, size: 30.0),
              onPressed: () {
                setState(() {
                  if(MediaQuery.of(context).orientation ==
                      Orientation.landscape) {
                    widget.isFullscreen?.value = false;
                    setState(() {
                      _isFullscreen = false;
                    });
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitDown,
                      DeviceOrientation.portraitUp
                    ]);
                  }else {
                    widget.isFullscreen?.value = true;
                    setState(() {
                      _isFullscreen = true;
                    });
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight
                    ]);
                  }
                });
              }),
        ),
        Container(
          margin: EdgeInsets.only(left: videoWidth + videoMargin - 48),
          child: IconButton(
              icon:const Icon(Icons.settings, size: 26.0),
              onPressed: () {
                _position = _controller!.value.position;
                _seek = true;
                _settingModalBottomSheet(context);
                setState(() {});
              }),
        ),
        Container(
          //===== Ползунок =====//
          margin: EdgeInsets.only(
              top: videoHeight - 26, left: videoMargin), //CHECK IT
          child: _videoOverlaySlider(),
        )
      ],
    )
        : Center(
      child: Container(
        height: 5,
        width: videoWidth,
        margin: EdgeInsets.only(top: videoHeight - 5),
        child: VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors:const VideoProgressColors(
            playedColor: Color(0xFF22A3D2),
            backgroundColor: Color(0x5515162B),
            bufferedColor: Color(0x5583D8F7),
          ),
          padding:const EdgeInsets.only(top: 2),
        ),
      ),
    );
  }

  //=================== ПОЛЗУНОК ===================//
  Widget _videoOverlaySlider() {
    return ValueListenableBuilder(
      valueListenable: _controller!,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.hasError && value.isInitialized) {
          return Row(
            children: <Widget>[
              Container(
                width: 46,
                alignment:const Alignment(0, 0),
                child: Text(value.position.inMinutes.toString() +
                    ':' +
                    (value.position.inSeconds - value.position.inMinutes * 60)
                        .toString()),
              ),
              Container(
                height: 20,
                width: videoWidth - 92,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFF22A3D2),
                    backgroundColor: Color(0x5515162B),
                    bufferedColor: Color(0x5583D8F7),
                  ),
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                ),
              ),
              Container(
                width: 46,
                alignment: const Alignment(0, 0),
                child: Text(value.duration.inMinutes.toString() +
                    ':' +
                    (value.duration.inSeconds - value.duration.inMinutes * 60)
                        .toString()),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    if(widget.onVideoClosed != null)widget.onVideoClosed!();
    _controller!.dispose();
    super.dispose();
  }
}

class QualityLinks {
  String videoId;

  QualityLinks(this.videoId);

  getQualitiesSync() {
    return getQualitiesAsync();
  }

  Future<SplayTreeMap?> getQualitiesAsync() async {
    try {
      var response = await http
          .get(Uri.parse('https://player.vimeo.com/video/' + videoId + '/config'));
      var jsonData =
      jsonDecode(response.body)['request']['files']['progressive'];
      SplayTreeMap videoList = SplayTreeMap.fromIterable(jsonData,
          key: (item) => "${item['quality']} ${item['fps']}",
          value: (item) => item['url']);
      return videoList;
    } catch (error) {
      return null;
    }
  }
}