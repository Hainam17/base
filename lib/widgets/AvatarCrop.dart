// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_crop/image_crop.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:vhv_basic/global.dart';
//
// class AvatarCrop extends StatefulWidget {
//   final PickedFile file;
//   final int size;
//   final double ratio;
//   const AvatarCrop(this.file, {this.size: 500, this.ratio: 1.0});
//
//   @override
//   _AvatarCropState createState() => new _AvatarCropState();
// }
//
// class _AvatarCropState extends State<AvatarCrop> {
//   final cropKey = GlobalKey<CropState>();
//   File _preview;
//
//   @override
//   void initState() {
//     super.initState();
//     if(widget.file != null)_getPreview();
//   }
//
//
//   _getPreview() async{
//     _preview = await ImageCrop.sampleImage(
//       file: File(widget.file.path),
//       preferredSize: widget.size,
//     );
//     setState(() {});
//   }
//
//
//   @override
//   void dispose() {
//     super.dispose();
//     File(widget.file.path)?.delete();
//     _preview?.delete();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Text('Cắt ảnh'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//               child: _buildCroppingImage(),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(15),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 ButtonFlat(
//                   onPressed: () => appNavigator.pop(),
//                   textColor: Colors.white,
//                   child: Text('Hủy', style: TextStyle(color: Colors.white)),
//                 ),
//                 ButtonFlat(
//                   textColor: Colors.white,
//                   color: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   onPressed: (){
//                     _cropImage(context);
//                   },
//                   child: Text('Lưu lại', style: TextStyle(color: Colors.white)),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildCroppingImage() {
//     if(_preview != null) {
//       return Crop.file(_preview, aspectRatio: widget.ratio, key: cropKey);
//     }
//     return SizedBox();
//   }
//
//
//   Future<void> _cropImage(BuildContext context) async {
//     final scale = cropKey.currentState.scale;
//     final area = cropKey.currentState.area;
//     if (area == null) {
//       return;
//     }
//
//     // scale up to use maximum possible number of pixels
//     // this will sample image in higher resolution to make cropped image larger
//     final sample = await ImageCrop.sampleImage(
//       file: File(widget.file.path),
//       preferredSize: (widget.size / scale).round(),
//     );
//
//     final file = await ImageCrop.cropImage(
//       file: sample,
//       area: area,
//     );
//     sample.delete();
//     appNavigator.pop(file);
//   }
// }