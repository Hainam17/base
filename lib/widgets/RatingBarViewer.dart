import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class RatingBarViewer extends StatefulWidget {
  final double? itemSize;
  final double? space;
  final double? initialRating;
  final int? itemCount;
  final Color? color;
  final Color? unratedColor;
  final ValueChanged? onChanged;
  final MainAxisAlignment? mainAxisAlignment;

  const RatingBarViewer({Key? key, this.itemSize = 16, this.space = 5.0,
    this.initialRating = 0, this.itemCount = 5, this.color, this.unratedColor, this.onChanged, this.mainAxisAlignment}) : super(key: key);

  @override
  _RatingBarViewerState createState() => _RatingBarViewerState();
}

class _RatingBarViewerState extends State<RatingBarViewer> {
  late double initialRating;
  @override
  void initState() {
    initialRating = widget.initialRating??0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RatingBarViewer oldWidget) {
    initialRating = widget.initialRating??0;
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.start,
      children: List.generate(widget.itemCount!, (i) => Padding(
        padding: EdgeInsets.only(right: (widget.itemCount! == i)?0:widget.space!),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (widget.onChanged != null)?()async{
            setState(() {
              initialRating = parseDouble(i + 1);
            });
            widget.onChanged!(i + 1);
          }:null,
          child: SvgViewer('assets/icons/ic_star${initialRating<(i + 1)?'':'_selected'}.svg',
            package: 'vhv_basic', height: widget.itemSize, color: initialRating<(i + 1)?widget.unratedColor:widget.color,
          ),
        ),
      ))
    );
  }
}
