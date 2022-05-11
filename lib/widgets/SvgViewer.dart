import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgViewer extends StatelessWidget {
  final String svgName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final bool matchTextDirection;
  final String? package;
  const SvgViewer(this.svgName, {Key? key, this.width, this.color,
    this.fit:BoxFit.contain, this.matchTextDirection:false, this.height, this.package}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if(svgName.indexOf('http') == 0){
      return SvgPicture.network(svgName,
          matchTextDirection: matchTextDirection,
          width: width,
          height: height,
          fit: fit,
          color: color,
      );
    }
    return SvgPicture.asset(svgName,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      color: color,
      package: package,
    );
  }
}
