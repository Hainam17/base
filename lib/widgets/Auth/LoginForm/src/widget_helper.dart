import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Size? getWidgetSize(GlobalKey key) {
  final Size? renderBox = key.currentContext!.size;
  return renderBox;
}