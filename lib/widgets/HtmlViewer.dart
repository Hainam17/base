import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vhv_basic/import.dart';
import 'VideoPlayerAll.dart';
export 'package:flutter_html/html_parser.dart';
export 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
typedef CustomRenderFix = Widget Function(
    RenderContext context,
    Widget parsedChild,
    Map<String, String> attributes,
    dom.Element element,
    );
class HTMLViewer extends StatelessWidget {
  final String? content;
  final Map<String, Style>? style;
  final TextStyle? textStyle;
  final Map<String, CustomRenderFix>? customRender;
  final bool shrinkWrap;
  final Function(String value)? onLinkTap;
  final ImageErrorListener? onImageError;
  final Function(String value)? onImageTap;
  final List<String>? blacklistedElements;
  final Axis? scrollDirection;
  final int? maxLines;
  final TextOverflow? textOverflow;

  const HTMLViewer(this.content, {this.style, this.shrinkWrap: false, this.customRender,
    this.onLinkTap, this.onImageError, this.onImageTap, this.blacklistedElements, this.textStyle, this.maxLines, this.textOverflow,this.scrollDirection = Axis.horizontal});
  @override
  Widget build(BuildContext context) {
    Map<String, CustomRenderFix>? _customRender = customRender;
    Map<String, CustomRender>? _customRenderReal = {};
    if(_customRender == null)_customRender = {};
    if(!_customRender.containsKey('video')){
      _customRender['video'] = (RenderContext? context, Widget child, attr, element) {
        if(!empty(attr['src'])){
          return VideoPlayerAll(attr['src'], autoPlay: false);
        }
        return child;
      };
    }
    if(!_customRender.containsKey('table')){
      _customRender['table'] = (RenderContext? context, Widget child, attr, element) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: Theme.of(currentContext).cardColor,
            child: HtmlWidget(
              element.toString(),
            ),
          ),
        );
      };
    }
    // if(!_customRender.containsKey('img')){
    //   _customRender['img'] = (RenderContext? context, Widget child, attr, element) {
    //     String _img = attr['src']??'';
    //     return (!empty(_img))
    //         ? Container(
    //       child: Image.network(
    //         urlConvert(_img),
    //         width: (attr['width'] != null &&
    //             attr['width']!.indexOf('%') == -1)
    //             ? attr['width']!.parseDouble()
    //             : null,
    //       ),
    //       color: Colors.red,
    //     )
    //         : const SizedBox.shrink();
    //   };
    // }
    _customRender.forEach((key, value) {
      _customRenderReal.addAll({
        key: (RenderContext context, Widget child) {
          Map<String, String> _a = {};
          (context.tree.element)!.attributes.forEach((key, value) {
            _a.addAll({
              '$key': '$value'
            });
          });
          return value(context, child, _a, context.tree.element!);
        }
      });
    });
    return Html(
        data: """
              ${(content != null)?(content!.replaceAll(new RegExp(r"&nbsp;"), ' ').replaceAllMapped(RegExp(r'src\=\"([^\"]+)\"(\sdata-is-path="1")?'), (match) {
                String? _image = match.group(1);
          if(_image!.indexOf('http') == 0) {
          }else{
            _image = urlConvert(_image, !(match.group(2) != null && (match.group(2))!.contains('data-is-path="1"')));
          }
          return 'src="$_image"${match.group(2)??''}';
        }).replaceAll('http://','https://').replaceAll('st1:metricconverter', 'span')):''}
            """,
        shrinkWrap: shrinkWrap,
        onLinkTap: onLinkTap != null?(url, _, __, ___) {
          onLinkTap!(url!);
        }:(url, _, __, ___)async{
          if(url!.isPDFFile()){
            openFile(url);
          }else{
            if(!empty(factories['hasDownloadFile']) && (url.isOfficeFile() || url.isCompressedFile())){
              showMessage('File đang được tải về');
              // urlLaunch(urlConvert(url));
              final _res = await download(urlConvert(url), toDownloadFolder: true);
              if(_res != null){
                showMessage('Tải về thành công (${_res.substring(
                    _res.lastIndexOf('/') + 1)})', type: 'SUCCESS');
              }
            }else{
              urlLaunch(urlConvert(url));
            }
          }
        },
        onImageError: onImageError,
        onImageTap: onImageTap != null?(url, _, __, ___) {
          onImageTap!(url!);
        }:null,
        customRender: _customRenderReal,
        style: (style??{})..addAll({
          "body": Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero,maxLines: maxLines,textOverflow: textOverflow),
        }));
  }
}
