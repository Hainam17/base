import 'dart:async';
import 'package:vhv_basic/extension/datetime_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/extension/string_extension.dart';

class TimeAgo extends StatefulWidget {
  final DateTime time;
  final bool isShort;
  final bool upperFirstLetter;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final String? format;
  final dynamic blockTime;
  final bool isFull;

  const TimeAgo(this.time,
      {this.isShort: false,
      this.style,
      this.maxLines: 1,
      this.overflow: TextOverflow.ellipsis,
      this.upperFirstLetter: true, this.format, this.blockTime = 3, this.isFull = false});
  @override
  _TimeAgoState createState() => _TimeAgoState();
}

class _TimeAgoState extends State<TimeAgo> {
  Timer? _everySecond;
  @override
  void initState() {
    super.initState();
    _everySecond = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _everySecond?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('widget.isFull---${widget.isFull}');
    int _now = (new DateTime.now()).millisecondsSinceEpoch;
    int? _end;
    if(widget.blockTime is Duration){
      _end = (!empty(widget.blockTime)?widget.blockTime.inMilliseconds:604800000);
    }else if(widget.blockTime is num){
      _end = _now - ((new DateTime.now()).subtract(Duration(days: widget.blockTime.ceil()))).toStr('dd/MM/yyyy').toDateTime().millisecondsSinceEpoch;
    }
    if((_now - widget.time.millisecondsSinceEpoch > (_end??0))){
      return Text(widget.time.toStr(widget.format),
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow);
    }
    String _time = timeAgo(widget.time.subtract(Duration(seconds: differenceTime)),
        locale: '$currentLanguage${widget.isShort ? '_short' : ''}', hasShort: !widget.isFull);
    if (widget.upperFirstLetter)
      _time = '${_time[0].toUpperCase()}${_time.substring(1)}';
    return Text(
      _time,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
