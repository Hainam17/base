import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/widgets/ImageCache.dart';
import '../global.dart';

extension StringExtensionColombo on String {
  String stripTag() {
    RegExp _reg = new RegExp(
        r"(?:<style.+?>.+?</style>|<script.+?>.+?</script>|<(?:!|/?[a-zA-Z]+).*?/?>)");
    return this.replaceAll(RegExp('</(div|p)>'), ' ').replaceAll(_reg, '');
  }

  String lang(
      {List<String> args = const[]}) {
    final text = this.trArgs(args);
    if(['minute', 'second', 'hour'].contains(text)){
      if(args.length == 1 && RegExp(r'\d+').hasMatch(args[0]) && args[0].parseInt() > 1){
        return '${text}s';
      }
    }
    return text;
  }

  bool isOfficeFile(){
    return this.endsWith('.doc') || this.endsWith('.docx')
        || this.endsWith('.xls') || this.endsWith('.xlsx')
        || this.endsWith('.ppt') || this.endsWith('.pptx');
  }
  bool isPDFFile(){
    return this.endsWith('.pdf');
  }

  bool isCompressedFile(){
    return this.endsWith('.rar') || this.endsWith('.7z') || this.endsWith('.zip');
  }

  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }
  bool isPhoneLO() {
    RegExp _regExp = new RegExp(
      r"^(0|\+?856)(20[2,5,7,9]\d|30[2,5,7,9])\d{6}$",
      caseSensitive: false,
      multiLine: false,
    );
    return _regExp.hasMatch(this);
  }
  bool isPhoneVN() {
    RegExp _regExp = new RegExp(
      r"^(0|\+?84)(9[0-9]|8[1-9]|7[0-3,6-9]|5[2,5,6,8,9]|3[2-9]|2\d{2})\d{7}$",
      caseSensitive: false,
      multiLine: false,
    );
    return _regExp.hasMatch(this);
  }
  bool isPhoneForeign() {
    RegExp _regExp = new RegExp(
      r"^00\d{8,15}$",
      caseSensitive: false,
      multiLine: false,
    );
    return _regExp.hasMatch(this);
  }

  bool isEmailVN() {
    RegExp _reExp = new RegExp(
        r"^[a-zA-Z0-9][a-zA-Z0-9_\.\-]{1,63}@[a-z0-9_\.\-]{2,249}(\.[a-zA-Z0-9]{2,4}){1,2}$",
        caseSensitive: false,
        multiLine: false);
    return _reExp.hasMatch(this);
  }

  double ratio() {
    if (this != '') {
      RegExp _reExp =
          new RegExp(r"(\d+)\:(\d+)", caseSensitive: false, multiLine: false);
      final Iterable<Match> _matches = _reExp.allMatches(this.toString());
      for (Match m in _matches) {
        double _ratio = int.parse(m.group(1)!) / int.parse(m.group(2)!);
        return _ratio;
      }
    }
    return 16 / 9;
  }

  Widget view({dynamic ratio, double? width, double? height, bool noCache: false, bool isNetwork: true}) {
    if (ratio is String) {
      ratio = ratio.ratio();
    } else if (ratio is int) {
      ratio = double.parse(ratio.toString());
    }
    Widget? _imageWrap;
    if (this.indexOf('data:image') == 0) {
      RegExp _reExp = new RegExp(r"data:image/[^;]+;base64,",
          caseSensitive: false, multiLine: false);
      final _base64 = this.replaceAll(_reExp, '');
      _imageWrap = Image.memory(
        base64Decode(_base64),
        width: width,
        height: height,
      );
    } else {
      String _url;
      if (this.indexOf('/') == 0 || this.indexOf('upload/') == 0) {
        if (ratio != null) {
          _url = this.thumb(ratio, width);
        } else {
          _url = '${urlConvert(this)}';
        }
      } else if(this.indexOf('publish/thumbnail') == 0) {
        _url = urlConvert(this);
      }else{
        _url = this;
      }
      if (this.indexOf('assets/') == 0) {
        _imageWrap = Image.asset(
          _url,
          width: width,
          height: height,
        );
      }else if(_url.indexOf('http') == 0){
        _imageWrap = ImageCacheNetwork(_url, width: width, height: height,aspectRatio: ratio);
      }else{
        _imageWrap = Image.file(File(_url), width: width, height: height);
      }
    }
    if(!empty(ratio)){
      return AspectRatio(aspectRatio: ratio, child: Center(child: _imageWrap));
    }else{
      return _imageWrap;
    }
  }

  String date([String? format]) {
    String _format = format ?? 'dd/MM/yyyy';
    return DateFormat(_format).format(this.toString().toDateTime());
  }

  DateTime toDateTime() {
    if (this == '' || this == 'null') {
      return new DateTime.now();
    }
    RegExp _reExpNum =
        new RegExp(r"^\s*\d+\s*$", caseSensitive: false, multiLine: false);
    if (_reExpNum.hasMatch(this.toString()) == true) {
      return new DateTime.fromMillisecondsSinceEpoch(int.parse(this) * 1000);
    }
    RegExp _reExp =
        new RegExp(r"(\d{1,4})", caseSensitive: false, multiLine: false);
    final Iterable<Match> _matches = _reExp.allMatches(this.toString());
    int _index = 0;
    List<String> _formats = ['d', 'M', 'y', 'H', 'm', 's'];
    String _format = '';
    String _dateReFormat = '';
    if(_matches.length > 6){
      return DateTime.parse(this);
    }
    for (Match m in _matches) {
      if (m.group(1) != null) {
        String _separation = '';
        if (_index < 5) {
          _separation = (_index < 2) ? "/" : (_index == 2) ? " " : ":";
        }
        _format += '${_formats[_index]}$_separation';
        _dateReFormat += '${m.group(1)}$_separation';
      }
      _index++;
    }
    return DateFormat(_format).parse(_dateReFormat);
  }

  String thumb(dynamic ratio, [double? width]) {
    final double _width = width ?? 480;
    List<double> _thumbSites = [32, 64, 100, 150, 200, 480];
    double? _thumbSite;
    if(_width <= (_thumbSites.last + 200)) {
      _thumbSites.forEach((element) {
        if (_width >= element) {
          _thumbSite = element;
        }
      });
    }
    if (ratio is String) {
      ratio = ratio.ratio();
    } else if (ratio is int) {
      ratio = double.parse(ratio.toString());
    }
    if (ratio is double || ratio == null) {
      if ((this.indexOf('upload/') == 0 || this.indexOf('/upload/') == 0) && _thumbSite != null) {
        RegExp _reExp =
            new RegExp(r"(\d+)", caseSensitive: false, multiLine: false);
        final Match _matches = _reExp.firstMatch(this.toString())!;
        final String _site = _matches[0].toString();
        return '${app['domain'] ?? ''}/publish/thumbnail/$_site/${_thumbSite!.ceil()}x${!empty(ratio)?(_thumbSite! / ratio).ceil():_thumbSite!.ceil()}x${!empty(ratio)?'default':'width'}/${this.replaceFirst('/upload/', 'upload/')}';
      }
      return urlConvert(this);
    }
    return this;
  }
}
