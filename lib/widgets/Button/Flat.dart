import 'package:flutter/material.dart';

class ButtonFlat extends TextButton {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHighlightChanged;
  final MouseCursor? mouseCursor;
  final ButtonTextTheme? textTheme;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? color;
  final Color? disabledColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? shadowColor;
  final Brightness? colorBrightness;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final OutlinedBorder? shape;
  final Clip clipBehavior = Clip.none;
  final FocusNode? focusNode;
  final bool autoFocus = false;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Widget child;
  final double? height;
  final double? minWidth;
  final Size? minimumSize;
  final BorderSide? side;
  final double? elevation;
  ButtonFlat({this.shadowColor, this.minimumSize, this.side, this.onPressed, this.onLongPress, this.onHighlightChanged, this.mouseCursor,
      this.textTheme, this.textColor, this.disabledTextColor, this.color,
      this.disabledColor, this.focusColor, this.hoverColor,
      this.highlightColor, this.splashColor, this.colorBrightness,
      this.padding, this.visualDensity, this.shape, this.focusNode,
      this.materialTapTargetSize,required this.child, this.height, this.minWidth,this.elevation, Key? key}) : super(
      key: key,
      onLongPress: onLongPress,
    onPressed: onPressed,
    child: child,
    style: ButtonStyle(
      elevation:ButtonStyleButton.allOrNull<double>(elevation),
      textStyle: ButtonStyleButton.allOrNull<TextStyle>(TextStyle(color: textColor)),
      backgroundColor: ButtonStyleButton.allOrNull<Color>(color),
      foregroundColor: ButtonStyleButton.allOrNull<Color>(textColor),
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
    ),
  );
}

