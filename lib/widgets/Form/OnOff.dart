import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vhv_basic/helper/system.dart';

class FormOnOff extends StatefulWidget {
  @required
  final dynamic value;
  @required
  final Function(String)? onChanged;
  final String textOff;
  final String textOn;
  final Color colorOn;
  final Color colorOff;
  final double textSize;
  final Duration animationDuration;
  final IconData iconOn;
  final IconData iconOff;
  final Function? onTap;
  final Function? onDoubleTap;
  final Function? onSwipe;

  FormOnOff(
      {this.value = '0',
        this.textOff = "OFF",
        this.textOn = "ON",
        this.textSize = 14.0,
        this.colorOn = Colors.green,
        this.colorOff = Colors.grey,
        this.iconOff = Icons.close,
        this.iconOn = Icons.check,
        this.animationDuration = const Duration(milliseconds: 220),
        this.onTap,
        this.onDoubleTap,
        this.onSwipe,
        this.onChanged});

  @override
  _FormOnOffState createState() => _FormOnOffState();
}

class _FormOnOffState extends State<FormOnOff>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? animation;
  double value = 0.0;

  bool turnState = false;

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: widget.animationDuration);
    animation =
        CurvedAnimation(parent: animationController!, curve: Curves.easeInOut);
    animationController!.addListener(() {
      setState(() {
        value = animation!.value;
      });
    });
    turnState = !empty(widget.value);
    _determine();
  }

  @override
  Widget build(BuildContext context) {
    Color? transitionColor = Color.lerp(widget.colorOff, widget.colorOn, value);

    return GestureDetector(
      onDoubleTap: () {
        _action();
        if (widget.onDoubleTap != null) widget.onDoubleTap!();
      },
      onTap: () {
        _action();
        if (widget.onTap != null) widget.onTap!();
      },
      onPanEnd: (details) {
        _action();
        if (widget.onSwipe != null) widget.onSwipe!();
        //widget.onSwipe();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 64,
        decoration: BoxDecoration(
            color: transitionColor, borderRadius: BorderRadius.circular(50)),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(10 * value, 0), //original
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(right: 3),
                  alignment: Alignment.centerRight,
                  height: 22,
                  child: Text(
                    widget.textOff,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.textSize),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(10 * (1 - value), 0), //original
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 5),
                  alignment: Alignment.centerLeft,
                  height: 22,
                  child: Text(
                    widget.textOn,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.textSize),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(32 * value, 0),
              child: Transform.rotate(
                angle: lerpDouble(0, 2 * pi, value)!,
                child: Container(
                  height: 22,
                  width: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Opacity(
                          opacity: (1 - value).clamp(0.0, 1.0),
                          child: Icon(
                            widget.iconOff,
                            size: 20,
                            color: transitionColor,
                          ),
                        ),
                      ),
                      Center(
                          child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Icon(
                                widget.iconOn,
                                size: 20,
                                color: transitionColor,
                              ))),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _action() {
    _determine(changeState: true);
  }

  _determine({bool changeState = false}) {
    setState(() {
      if (changeState) turnState = !turnState;
      (turnState)
          ? animationController!.forward()
          : animationController!.reverse();

      widget.onChanged!(turnState?'1':'0');
    });
  }
}
