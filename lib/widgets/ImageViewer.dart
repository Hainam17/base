import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/widgets/ImageCache.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:get/get.dart';

class ImageViewer extends StatefulWidget {
  final dynamic ratio;
  final double? width;
  final double? height;
  final bool noCache;
  final String image;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final bool? matchTextDirection;
  final bool notThumb;
  final String? package;
  final Color? color;
  final double? widthThumb;
  final LoadingErrorWidgetBuilder? errorBuilder;
  const ImageViewer(this.image, {Key? key, this.ratio, this.width, this.height, this.noCache = false,
    this.fit = BoxFit.cover, this.errorWidget, this.placeholder, this.matchTextDirection,
    this.package, this.color, this.errorBuilder, this.notThumb = false, this.widthThumb}) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  Future<String> _getImage(String image)async{
    final _res = await post(image, cacheTime: Duration(hours: 1), forceRefresh: false);
    return _res;
  }
  int counterTry = 3;
  @override
  Widget build(BuildContext context) {
    if(widget.image == ''){
      return const SizedBox.shrink();
    }
    if(widget.image.contains('tex.vdoc.vn')){
      return FutureBuilder<String>(
        future: _getImage(widget.image),
        builder: (_, snapshot){
          if(snapshot.hasData && snapshot.data is String) {
            final String svg = snapshot.data!.substring(0, snapshot.data!.indexOf('>'));
            final a = RegExp(r'<svg.+width="([^\"]+)".+height="([^\"]+)"').allMatches(svg);
            final width = a.first.group(1);
            final height = a.first.group(2);
            double? w;
            double? h;
            if(width.toString().endsWith('ex') || width.toString().endsWith('px')){
              w = parseDouble(width.toString().replaceAll('ex', ''))
                  * (width.toString().endsWith('ex')?7:1);
            }
            if(height.toString().endsWith('ex') || height.toString().endsWith('px')){
              h = parseDouble(height.toString().replaceAll('ex', ''))
                  * (height.toString().endsWith('ex')?7:1);
            }
            return SvgPicture.string(
              snapshot.data!.replaceAll('currentColor', 'black'),
              height: h,
              width: w,
            );
          }
          return const SizedBox.shrink();
        },
      );
    }
    if(widget.image.endsWith('.svg')){
      if(widget.image.indexOf('http') == 0){
        return SvgPicture.network(widget.image,
            matchTextDirection: widget.matchTextDirection??false,
            width: widget.width,
            height: widget.height,
            fit: widget.fit??BoxFit.contain,
            color: widget.color
        );
      }
      return SvgPicture.asset(widget.image,
        matchTextDirection: widget.matchTextDirection??false,
        width: widget.width,
        height: widget.height,
        fit: widget.fit??BoxFit.contain,
        color: widget.color,
        package: widget.package,
      );
    }
     double? _ratio;
    if (widget.ratio is String) {
      _ratio = widget.ratio.ratio();
    } else if (widget.ratio is int) {
      _ratio = double.parse(widget.ratio.toString());
    }else if(widget.ratio is double){
      _ratio = widget.ratio;
    }
    Widget? _imageWrap;
    if (widget.image.startsWith('data:image')) {
      RegExp _reExp = new RegExp(r"data:image/[^;]+;base64,",
          caseSensitive: false, multiLine: false);
      final _base64 = widget.image.replaceAll(_reExp, '');
      _imageWrap = Image.memory(
        base64Decode(_base64),
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (_, __, ___){
          return widget.errorWidget??Container(color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(child: Icon(Icons.error_outline)));
        },
      );
    } else {
      String _url;
      // String? thumb;
      // double _widthThumb = ((widget.width??480)/15);
      if (widget.image.startsWith('upload/')) {
        if (_ratio != null) {
          _url = widget.image.thumb(_ratio, widget.width);
          // thumb = widget.image.thumb(_ratio, _widthThumb);
        } else {
          if(widget.notThumb || Get.width > 600){
            _url = urlConvert(widget.image);
          }else{
            _url = widget.image.thumb(null, widget.widthThumb??widget.width);
          }

          // thumb = widget.image.thumb(null, _widthThumb);
        }
      } else if(widget.image.startsWith('publish/thumbnail')) {
        _url = '${app['staticDomain']}/${widget.image}';
      }else{
        _url = urlConvert(widget.image);
      }

      if ((widget.image.startsWith('assets/'))) {
        _imageWrap = Image.asset(
          _url,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          package: widget.package,
          errorBuilder: (_, __, ___){
            return widget.errorWidget??Container(color: Theme.of(context).scaffoldBackgroundColor, child: Center(child: Icon(Icons.error_outline)));
          },
        );
      }else if(_url.startsWith('http')){
        if(widget.noCache || isWeb){
          print('_url2-------------$_url');
          _imageWrap = Image.network(_url, width: widget.width, height: widget.height);
        }else{
          _imageWrap = ImageCacheNetwork(_url, key: ValueKey('$_url--$counterTry'), width: widget.width,
            height: widget.height,
            aspectRatio: _ratio, placeholder: widget.placeholder,
            // imageThumbnail: thumb,
            fit: widget.fit,
            errorWidget: widget.errorWidget,
            errorBuilder: widget.errorBuilder??(_, __, ___){
            Future.delayed(const Duration(seconds: 2),(){
              if(mounted && counterTry > 0){
                setState(() {
                  counterTry--;
                });
              }
            });
                return widget.errorWidget ?? Container(
                  color: Theme
                      .of(context)
                      .scaffoldBackgroundColor,
                  child: Center(child: (counterTry == 0)?Icon(Icons.error_outline):const SizedBox(
                    width: 10,
                    height: 10,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ))
                );
            });
        }
      }else{
        print('Image.file------------$_url');
        _imageWrap = Image.file(File(_url), width: widget.width, height: widget.height, fit: widget.fit, errorBuilder: (_, __, ___){
          return widget.errorWidget??Container(color: Theme.of(context).scaffoldBackgroundColor, child: Center(child: Icon(Icons.error_outline)));
        });
      }
    }
    if(!empty(_ratio)){
      return AspectRatio(aspectRatio: _ratio!, child: Center(child: _imageWrap));
    }else{
      return _imageWrap;
    }
  }
}
