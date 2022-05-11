import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class Avatar extends StatelessWidget {
  final String fullName;
  final dynamic image;
  final double width;
  final double? radius;
  final Color? color;
  const Avatar(this.fullName, {this.image, this.width:40, this.radius, this.color});
  @override
  Widget build(BuildContext context) {
    final String _first = (!empty(fullName))?(fullName.split(' ').length > 0?fullName.trim().split(' ').last[0]:fullName):'';
    final Color _color = color??_convertColor(_first);
    final _fontSize = width/2;
    String _image = !empty(image) && image is String ? image : '';
    Widget? _imageWidget;
    List<dynamic> _images;
    if(!empty(image) && (image is Map || image is List)){
      _images = (image is Map)?image.values.toList():image;
      if(_images.length == 1){
        _image = !empty(_images[0]) ? _images[0] : '';
      }else{
        _imageWidget = Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            SizedBox(
              width: width,
              height: width,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.all(Radius.circular(radius??width))
                  ),
                  child: Avatar('', image: _images[0], width: width * ((_images.length > 2)?0.55:0.65), )
              )
            ),
            if(_images.length > 2)Positioned(
                top: 0,
                left: 0,
                child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.all(Radius.circular(radius??width))
                    ),
                    child: Avatar('', image: _images[0], width: width * 0.4)
                )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(radius??width))
                ),
                child: Avatar('', image: _images[1], width: width * 0.65)
              )
            ),
          ],
        );
      }
    }
    if(_imageWidget != null){
      return _imageWidget;
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius??(width))),
      child: SizedBox(
          width: width,
          height: width,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: _imageWidget??Container(
              color: (empty(_image))?_color:null,
              child: Center(
                child: Builder(
                  builder: (_){
                    if(!empty(_image)){
                      return ImageViewer(urlConvert(_image), ratio: 1, width: width,fit: BoxFit.cover,height: width);
                    }
                    return Text(
                      _first.toUpperCase(),
                      style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, color: Colors.white),
                    );
                  }
                ),
              ),
            ),
          )
      ),
    );
  }
}
Color _convertColor(String firstText){
  switch(firstText.toUpperCase()){
    case 'Q':
      return Color(0xff7e57c2);
    case 'W':
      return Color(0xfff06292);
    case 'E':
      return Color(0xffab47bc);
    case 'R':
      return Color(0xffef5350);
    case 'T':
      return Color(0xff03a9f4);
    case 'Y':
      return Color(0xff00acc1);
    case 'U':
      return Color(0xff8bc34a);
    case 'I':
      return Color(0xff66bb6a);
    case 'O':
      return Color(0xff26a69a);
    case 'P':
      return Color(0xffffa726);
    case 'A':
      return Color(0xffffca28);
    case 'S':
      return Color(0xffff7043);
    case 'D':
      return Color(0xff8d6e63);
    case 'F':
      return Color(0xff29b6f6);
    case 'G':
      return Color(0xff42a5f5);
    case 'H':
      return Color(0xffa1887f);
    case 'J':
      return Color(0xff7e57c2);
    case 'K':
      return Color(0xfff06292);
    case 'L':
      return Color(0xffab47bc);
    case 'Z':
      return Color(0xffef5350);
    case 'X':
      return Color(0xff03a9f4);
    case 'C':
      return Color(0xff00acc1);
    case 'V':
      return Color(0xff8bc34a);
    case 'B':
      return Color(0xff66bb6a);
    case 'N':
      return Color(0xff26a69a);
    case 'M':
      return Color(0xffffa726);
    case 'Đ':
      return Color(0xffffca28);
    case 'Ô':
      return Color(0xffff7043);
    case 'Ơ':
      return Color(0xff8d6e63);
    case 'Ă':
      return Color(0xff29b6f6);
    case 'Ê':
      return Color(0xff42a5f5);
    default:
      return Colors.blue;
  }
}
