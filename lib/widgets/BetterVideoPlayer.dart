import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'dart:io' as io;

import 'package:vhv_basic/libs/DioLib.dart';

class BetterVideoPlayer extends StatefulWidget {
  final String? videoLink;
  final bool? autoPlay;
  final bool? isFullScreen;
  final double? ratio;
  final bool? hasDownload;
  final Function(BetterPlayerController controller)? getController;
  final bool? hideFullScreen;
  final bool? hideSpeedControl;
  final Map? options;

  const BetterVideoPlayer({Key? key, this.videoLink, this.autoPlay,
    this.isFullScreen, this.getController, this.ratio, this.hasDownload = false,
    this.hideFullScreen = false, this.hideSpeedControl = false, this.options}) : super(key: key);
  @override
  _BetterVideoPlayerState createState() => _BetterVideoPlayerState();
}

class _BetterVideoPlayerState extends State<BetterVideoPlayer> {
  BetterPlayerController? _betterPlayerController;
  double ratio = 16/9;
  ValueNotifier<bool>? _hasDownload;

  @override
  void dispose() {
    _hasDownload?.dispose();
    if(!isWeb && io.Platform.isIOS)SystemChrome.setPreferredOrientations(appOrientations);
    super.dispose();
  }
  @override
  void initState() {
    _betterPlayerController?.dispose();
    if(widget.hasDownload!)_hasDownload = ValueNotifier(false);
    _init();
    super.initState();
  }

  bool _getOption(String key,bool defaultValue){
    if(widget.options is Map && widget.options!.containsKey(key))return widget.options![key];
    return defaultValue;
  }
  _init()async{
    BetterPlayerConfiguration betterPlayerConfiguration =
    BetterPlayerConfiguration(
        deviceOrientationsAfterFullScreen: appOrientations,
        aspectRatio: (widget.ratio??ratio),
        fit: BoxFit.contain,
        autoPlay: widget.autoPlay??true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: false,
          enableOverflowMenu: false,
          controlBarHeight: 40,
          enableFullscreen: empty(factories['hideFullScreenButton']??widget.hideFullScreen),
          enablePlaybackSpeed: empty(factories['hideVideoSpeedButton']??widget.hideSpeedControl),
          enableProgressBarDrag: _getOption('enableProgressBarDrag', true)
        )
    );
    List<Cookie> cookies = await getCookies();
    String cookie = '';
    cookies.forEach((element) {
      if (element.name == 'AUTH_BEARER_default') {
        cookie = element.toString();
      }
    });
    final bool _hasFile = (widget.videoLink.toString().startsWith('http') || widget.videoLink.toString().startsWith('upload/'))?false:await io.File(widget.videoLink!).exists();
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        _hasFile?BetterPlayerDataSourceType.file:BetterPlayerDataSourceType.network,
        _hasFile?widget.videoLink:urlConvert(widget.videoLink!),
      headers: {
          'Cookie': cookie
      }
   );
    print({
      'Cookie': cookie
    });
    _betterPlayerController =
        BetterPlayerController(betterPlayerConfiguration);
    setState(() {

    });
    await _betterPlayerController!.setupDataSource(dataSource);
    if(widget.ratio == null && ((_betterPlayerController!.videoPlayerController)!.value.aspectRatio != ratio)){
      setState(() {
        ratio = (_betterPlayerController!.videoPlayerController)!.value.aspectRatio;
      });
      if(ratio <= 0){
        setState(() {
          ratio = 3/2;
        });
      }
      _betterPlayerController!.setOverriddenAspectRatio(ratio);
    }
    if(widget.getController != null){
      widget.getController!(_betterPlayerController!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!empty(widget.videoLink)) {
      return AspectRatio(
        aspectRatio: ('${widget.ratio ?? ratio}' != 'NaN') ? widget.ratio ??
            ratio : 3 / 2,
        child: (_betterPlayerController != null) ? BetterPlayer(
            controller: _betterPlayerController!)
            : const SizedBox(
          child:const Center(
            child: const Icon(Icons.video_collection_rounded),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 3/2,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Text('Video chưa sẵn sàng!'.lang(), style:const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}