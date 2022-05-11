import 'package:flutter/material.dart';

class ButtonRaised extends ElevatedButton{
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHighlightChanged;
  final MouseCursor? mouseCursor;
  final ButtonTextTheme? textTheme;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? color;
  final Color? shadowColor;
  final Color? disabledColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Brightness? colorBrightness;
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final EdgeInsetsGeometry? padding;
  final VisualDensity? visualDensity;
  final OutlinedBorder? shape;
  final Clip clipBehavior = Clip.none;
  final FocusNode? focusNode;
  final bool autofocus = false;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Duration? animationDuration;
  final Widget? child;
  final Size? minimumSize;
  final BorderSide? side;
  ButtonRaised({this.shadowColor, this.side, this.minimumSize, this.onPressed, this.onLongPress, this.onHighlightChanged, this.mouseCursor,
  this.textTheme, this.textColor, this.disabledTextColor, this.color, this.disabledColor,
  this.focusColor, this.hoverColor, this.highlightColor, this.splashColor,
  this.colorBrightness, this.elevation, this.focusElevation, this.hoverElevation,
  this.highlightElevation, this.disabledElevation, this.padding, this.visualDensity,
  this.shape, this.focusNode, this.materialTapTargetSize,
    this.animationDuration,@required this.child, Key? key}):super(
    key: key,
    child: child,
    onPressed: onPressed,
    onLongPress: onLongPress,
    style: ButtonStyle(
      textStyle: ButtonStyleButton.allOrNull<TextStyle>(TextStyle(color: textColor)),
      backgroundColor: ButtonStyleButton.allOrNull<Color>(color),
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      elevation: ButtonStyleButton.allOrNull<double>(elevation),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
    )
  );
}