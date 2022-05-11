// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//
// class FormColorPicker extends StatefulWidget {
//   final Color? color;
//
//   FormColorPicker({this.color});
//
//   @override
//   _FormColorPickerState createState() => _FormColorPickerState();
// }
//
// class _FormColorPickerState extends State<FormColorPicker> {
//   Color? color;
//
//   @override
//   void initState() {
//     super.initState();
//     color = widget.color;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       titlePadding: const EdgeInsets.all(0.0),
//       contentPadding: const EdgeInsets.all(0.0),
//       content: SingleChildScrollView(
//         child: ColorPicker(
//           pickerColor: color!,
//           onColorChanged: (pickedColor) {
//             color = pickedColor;
//             setState(() {});
//           },
//           colorPickerWidth: 300.0,
//           pickerAreaHeightPercent: 0.7,
//           enableAlpha: true,
//           displayThumbColor: true,
//           showLabel: true,
//           paletteType: PaletteType.hsv,
//           pickerAreaBorderRadius: const BorderRadius.only(
//             topLeft: const Radius.circular(2.0),
//             topRight: const Radius.circular(2.0),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, color),
//           child: Text('Done'),
//         )
//       ],
//     );
//   }
// }
