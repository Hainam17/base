import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/VimeoVideoPlayer.dart';
import 'package:vhv_basic/widgets/YoutubePlay.dart';
import 'BetterVideoPlayer.dart';
// import 'media/desktop_video_player.dart';

enum VideoType{youtube, vimeo, upload}
class VideoPlayerAll extends StatefulWidget {
  final String? link;
  final bool? autoPlay;
  final Widget Function(BuildContext, Widget)? builder;
  final Function? onVideoClosed;
  final Map? options;

  const VideoPlayerAll(this.link, {Key? key, this.builder, this.autoPlay,
    this.onVideoClosed, this.options}) : super(key: key);
  @override
  _VideoPlayerAllState createState() => _VideoPlayerAllState();
}

class _VideoPlayerAllState extends State<VideoPlayerAll> {
  VideoType _videoType = VideoType.upload;
  RegExp? _reExpVimeo;
  late String _id = '';
  @override
  void initState() {
    RegExp _reExpId = new RegExp(
        r'(?:youtube\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/\s]{11})',
        caseSensitive: false,
        multiLine: false);
    _reExpVimeo = new RegExp(
        r'(http|https)?://(www\.)?vimeo.com/(([^/]*)/videos/|)(\d+)(?:|/\?)',
        caseSensitive: false,
        multiLine: false);
    if (_reExpId.hasMatch(widget.link!)) {
      _videoType = VideoType.youtube;
      if(mounted)setState(() {});
    }else if(_reExpVimeo!.hasMatch(widget.link!)){
      _videoType = VideoType.vimeo;
      final Iterable<Match> _matches = _reExpVimeo!.allMatches(widget.link!);
      for (Match m in _matches) {
        if (m.group(5) != null) {
          _id =  m.group(5).toString();
        }
      }
      if(mounted)setState(() {});
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    switch(_videoType){
      case VideoType.youtube:
        return YoutubePlay(widget.link,
          builder: (widget.builder != null)?(context, player){
            return widget.builder!(context, player);
          }:null,
          autoPlay: widget.autoPlay,
          onVideoClosed: widget.onVideoClosed,
        );
      case VideoType.vimeo:
        if(!empty(_id)){
          if(widget.builder == null) {
            return VimeoVideoPlayer(id: _id, autoPlay: widget.autoPlay, onVideoClosed: widget.onVideoClosed);
          }else{
            return widget.builder!(context, VimeoVideoPlayer(id: _id, autoPlay: widget.autoPlay, onVideoClosed: widget.onVideoClosed));
          }
        }
        return const SizedBox.shrink();
      default:
        if (widget.builder == null) {
          if(Platform.isWindows || Platform.isLinux){
            return const AspectRatio(aspectRatio: 3/2);
            // return DesktopVideoPlayer(videoLink: widget.link, autoPlay: widget.autoPlay);
          }
          return BetterVideoPlayer(videoLink: widget.link, options: widget.options, autoPlay: widget.autoPlay);
        } else {
          return widget.builder!(context,
              (Platform.isWindows || Platform.isLinux)
                ?AspectRatio(aspectRatio: 3/2)
                // ?DesktopVideoPlayer(videoLink: widget.link, autoPlay: widget.autoPlay)
                :BetterVideoPlayer(videoLink: widget.link, options: widget.options, autoPlay: widget.autoPlay)
          );
        }

    }
  }
}
