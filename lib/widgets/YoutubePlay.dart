import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_basic/import.dart';

class YoutubePlay extends StatefulWidget {
  final String? link;
  final String? videoId;
  final bool? autoPlay;
  final ValueNotifier? listener;
  final StreamSink? valueListener;
  final YoutubePlayerController? controller;
  final Widget Function(BuildContext, Widget)? builder;
  final Function? onVideoClosed;
  final bool? hideFullScreen;
  final bool? hideSpeedControl;

  const YoutubePlay(this.link,
      {this.autoPlay: true,
      this.videoId,
      this.valueListener,
      this.controller,
      this.listener,
      this.builder,
      this.onVideoClosed,
      this.hideFullScreen = false,
      Key? key,
      this.hideSpeedControl = false}):super(key: key);
  @override
  _YoutubePlayState createState() => _YoutubePlayState();
}

class _YoutubePlayState extends State<YoutubePlay> {
  YoutubePlayerController? _controller;
  String? videoId;
  @override
  void initState() {
    super.initState();
    if (!empty(widget.link)) {
      videoId = widget.videoId ?? YoutubePlayer.convertUrlToId(widget.link!);
      if (empty(videoId)) {
        Match match = RegExp(
                r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?.*\&v=([_\-a-zA-Z0-9]{11}).*$")
            .firstMatch(widget.link!)!;
        if (match.groupCount >= 1) videoId = match.group(1);
      }
      // if (empty(videoId) && widget.link != null) {
      //   Match? match = RegExp(
      //       r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?.*\&v=([_\-a-zA-Z0-9]{11}).*$")
      //       .firstMatch(widget.link!);
      //   if (match != null && match.groupCount >= 1) videoId = match.group(1);
      // }
    }
    if (!empty(videoId)) {
      _controller = widget.controller ??
          YoutubePlayerController(
            initialVideoId: videoId!,
            flags: YoutubePlayerFlags(
                mute: false,
                autoPlay: widget.autoPlay ?? true,
                loop: false,
                hideThumbnail: true,
                isLive: false,
                forceHD: false,
                enableCaption: false,
                disableDragSeek: !empty(factories['hideVideoProcessBar'])),
          );
      _controller!.addListener(_listener);
    }
  }

  _listener() async {
    widget.valueListener?.add(_controller!.value);
    widget.listener?.value = _controller!.value;
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    if (widget.onVideoClosed != null) widget.onVideoClosed!();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!empty(videoId)) {
      if (!empty(factories['hideFullScreenButton']??widget.hideFullScreen)) {
        return YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: false,
          progressIndicatorColor: Colors.blueAccent,
          bottomActions: !empty(factories['hideVideoProcessBar'])
              ? [
                  const SizedBox(width: 14.0),
                  CurrentPosition(),
                  const SizedBox(width: 8.0),
                  Spacer(),
                ]
              : [
                  const SizedBox(width: 14.0),
                  CurrentPosition(),
                  const SizedBox(width: 8.0),
                  ProgressBar(
                    isExpanded: true,
                  ),
                  RemainingDuration(),
                  if (empty(factories['hideVideoSpeedButton']??widget.hideSpeedControl))
                    const PlaybackSpeedButton(),
                ],
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller!.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: () {},
            ),
          ],
          onReady: () {},
          onEnded: (data) async {
            Future.delayed(const Duration(milliseconds: 300), () async {
              _controller!.seekTo(Duration.zero);
              _controller!.play();
              _controller!.pause();
            });
          },
        );
      }
      return YoutubePlayerBuilder(
          onEnterFullScreen: () {
            if (empty(factories['hideFullScreenButton']??widget.hideFullScreen))
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]);
            if (_controller!.value.isPlaying) {
              _controller!.play();
            }
          },
          onExitFullScreen: () {
            if (empty(factories['hideFullScreenButton']??widget.hideFullScreen)) {
              SystemChrome.setPreferredOrientations(appOrientations);
            }
            if (_controller!.value.isPlaying) {
              _controller!.play();
            }
          },
          player: YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: false,
            progressIndicatorColor: Colors.blueAccent,
            bottomActions: !empty(factories['hideVideoProcessBar'])
                ? [
                    const SizedBox(width: 14.0),
                    CurrentPosition(),
                    const SizedBox(width: 8.0),
                    Spacer(),
                    if (empty(factories['hideFullScreenButton']??widget.hideFullScreen)) FullScreenButton(),
                  ]
                : [
                    const SizedBox(width: 14.0),
                    CurrentPosition(),
                    const SizedBox(width: 8.0),
                    ProgressBar(
                      isExpanded: true,
                    ),
                    RemainingDuration(),
                    if (empty(factories['hideVideoSpeedButton']??widget.hideSpeedControl))
                      const PlaybackSpeedButton(),
                    if (empty(factories['hideFullScreenButton']??widget.hideFullScreen)) FullScreenButton(),
                  ],
            topActions: <Widget>[
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _controller!.metadata.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 25.0,
                ),
                onPressed: () {},
              ),
            ],
            onReady: () {},
            onEnded: (data) async {
              Future.delayed(const Duration(milliseconds: 300), () async {
                _controller!.seekTo(Duration.zero);
                _controller!.play();
                _controller!.pause();
              });
            },
          ),
          builder: (context, player) {
            if (widget.builder != null) {
              return widget.builder!(context, player);
            } else {
              return Material(
                child: player,
              );
            }
          });
    }
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: YoutubePlayerController(initialVideoId: ''),
        ),
        builder: (context, player) {
          if (widget.builder != null) {
            return widget.builder!(context, player);
          } else {
            return const Material(
              child: const SizedBox.shrink(),
            );
          }
        });
  }
}
