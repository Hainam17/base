// import 'package:dart_vlc/dart_vlc.dart';
// import 'package:flutter/material.dart';
//
// class DesktopVideoPlayer extends StatefulWidget {
//   final String? videoLink;
//   final bool? autoPlay;
//   final bool? isFullScreen;
//   final double? ratio;
//   const DesktopVideoPlayer({Key? key, this.videoLink, this.autoPlay = true, this.isFullScreen, this.ratio = 3/2}) : super(key: key);
//
//   @override
//   _DesktopVideoPlayerState createState() => _DesktopVideoPlayerState();
// }
//
// class _DesktopVideoPlayerState extends State<DesktopVideoPlayer> {
//   Player player = Player(id: 0);
//
//   @override
//   void initState() {
//     player.open(
//       Media.network(
//           widget.videoLink
//       ),
//       autoStart: widget.autoPlay??true, // default
//     );
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, boxConstraints){
//         final width = boxConstraints.maxWidth;
//         final height = width/widget.ratio!;
//         return Video(
//           player: player,
//           width: width,
//           height: height,
//           volumeThumbColor: Colors.blue,
//           volumeActiveColor: Colors.blue,
//           playlistLength: 1,
//         );
//       },
//     );
//   }
// }
