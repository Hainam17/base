import 'dart:async';
import 'dart:io';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/BetterVideoPlayer.dart';
import 'package:video_player/video_player.dart';

import 'media/desktop_video_player.dart';
class VideoPlay extends StatefulWidget {
  final String? videoLink;
  final StreamSink? valueListener;
  final bool? autoPlay;
  final bool? isFullScreen;
  final VideoPlayerController? controller;
  final BetterPlayerController? playerController;
  final Function? onVideoClosed;
  final bool? hideFullScreen;
  final bool? hideSpeedControl;

  const VideoPlay({Key? key, this.videoLink, this.valueListener, this.autoPlay, this.isFullScreen,
    this.controller, this.playerController, this.onVideoClosed,
    this.hideFullScreen = false, this.hideSpeedControl = false, }) : super(key: key);

  @override
  _VideoPlayState createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {

  @override
  void dispose() {
    if(widget.onVideoClosed != null)widget.onVideoClosed!();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(Platform.isLinux || Platform.isWindows) {
      return const AspectRatio(aspectRatio: 3/2);
      // return DesktopVideoPlayer(
      //   videoLink: widget.videoLink,
      //   autoPlay: widget.autoPlay,
      //   isFullScreen: widget.isFullScreen,
      // );
    }
    return BetterVideoPlayer(
      videoLink: widget.videoLink,
      autoPlay: widget.autoPlay,
      isFullScreen: widget.isFullScreen,
      hideSpeedControl: widget.hideSpeedControl,
      hideFullScreen: widget.hideFullScreen,
    );

  }
}