export 'helper/locale.dart';
export 'helper/system.dart';
export 'helper/time.dart';
export 'helper/media.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vhv_basic/widgets/BottomSheetMenu.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'import.dart';
export 'package:video_player/video_player.dart';
export 'package:youtube_player_flutter/youtube_player_flutter.dart';
export 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


bool isLocal(){
  return (app['domain'].toString().contains('192.168.1.130')
      || app['domain'].toString().endsWith('coquan.vn'));
}
bool get isWeb => kIsWeb;

String routerConvert([String? page]) {
  if(factories['routerConvert'] != null)return factories['routerConvert'](page);
  if(page!.indexOf('http') == 0){
    return '';
  }
  if (page != '') {
    List<String> _pages = page.split('.');
    if (_pages.first == 'Mobile') {
      _pages.removeAt(0);
    }
    if (_pages.last == 'list') {
      _pages.removeLast();
    } else {
      final String _last =
          _pages.last[0].toUpperCase() + _pages.last.substring(1);
      _pages.removeLast();
      _pages.add(_last);
    }
    return '/' + _pages.join('/');
  }
  return '';
}
linkToRouter(String link){
  if (!empty(link)) {
    final Uri url = Uri.parse(link);
    String? _page = url.queryParameters['page'];
    Map _params = {};
    if (!empty(_page)) {
      _params.addAll(url.queryParameters);
      _params.remove('page');
    } else if (url.pathSegments.length > 0 && inArray(url.pathSegments[0], ['u','g'])) {
      _page = url.pathSegments[0];
      _params['id'] = url.pathSegments[1];
    }
    if (_page != null) {
      final _router = (factories['routerConvert'] != null)?factories['routerConvert'](_page):routerConvert(_page);
      if(!empty(_router)){
        appNavigator.pushNamed(_router, arguments: _params);
        return true;
      }
    }
  }
  return false;
}

String htmlDecode(var html){
  if(html != null) {
    return HtmlUnescape().convert(html.toString());
  }
  return '';
}

String noTag(var html){
  if(html != null) {
    return HtmlUnescape().convert(html.toString());
  }
  return '';
}

String quote(var html){
  if(html != null) {
    return HtmlUnescape().convert(html.toString());
  }
  return '';
}

Future<String> getDownloadDir(String url)async{
  var tempDir = await getApplicationDocumentsDirectory();
  String _fileName = url.substring(url.lastIndexOf('/') + 1);
  String? savePath;
  if(!isWeb) {
    if (Platform.isIOS) {
      savePath = tempDir.path + '/' + _fileName;
    } else {
      Directory? _downloadsDirectory = await DownloadsPathProvider
          .downloadsDirectory;
      savePath = '${_downloadsDirectory!.path}/$_fileName';
    }
  }
  return savePath??'';
}

urlLaunch(String url,{bool forceWebView = false}) async {
  if (await canLaunch(urlConvert(url))) {
    return await launch(urlConvert(url), forceWebView: forceWebView);
  } else {
    // throw 'Could not launch $url';
    showMessage('Không thể tìm thấy đường dẫn ${urlConvert(url)}');
  }
}

Future<void> urlLaunchUniversalLinkIos(String url) async {
  if (await canLaunch(url)) {
    final bool nativeAppLaunchSucceeded = await launch(
      url,
      forceSafariVC: false,
      forceWebView: false);
    if (!nativeAppLaunchSucceeded) {
      await launch(
        url,
        forceSafariVC: true,
      );
    }
  }
}





Future<void> callTo(String phone) async {
  if (await canLaunch("tel:$phone")) {
    await launch(phone);
  } else {
    throw 'Could not tel to $phone';
  }
}
String lang(String text){
  return text.lang();
}
Future<void> smsTo(String phone) async {
  if (await canLaunch("sms:$phone")) {
    await launch(phone);
  } else {
    throw 'Could not send sms to $phone';
  }
}

Future<void> mailTo(String email, [String? subject]) async {
  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject??''
      }
  );
  launch(_emailLaunchUri.toString());
}



showFullModal({
  bool barrierDismissible = true,
  required Widget child,
  WillPopCallback? onWillPop,
})async{
  return await showDialog<void>(
      context: currentContext,
      useSafeArea: false,
      barrierDismissible: barrierDismissible, // us
      // er must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: ()async{
            if(onWillPop != null)return await onWillPop();
            return true;
          },
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: child,
          ),
        );
      }
  );
}

showModal({
  String? title,
  TextStyle? titleStyle,
  Widget? content,
  String? middleText,
  Widget? cancel,
  List<Widget>? actions,
  VoidCallback? onCancel,
  VoidCallback? onCustom,
  VoidCallback? onConfirm,
  Color? confirmTextColor,
  String? textConfirm,
  String? textCancel,
  String? textCustom,
  bool barrierDismissible = true,
  double radius = 10.0,
  WillPopCallback? onWillPop,
})async{
  return await showDialog<void>(
      context: currentContext,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: ()async{
            if(onWillPop != null)return await onWillPop();
            return true;
          },
          child: Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(!empty(title))Text(title!, textAlign: TextAlign.center, style: Theme.of(currentContext).textTheme.headline6),
                  if(!empty(title))SizedBox(height: 20),
                  Flexible(child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        !empty(middleText)?Text(middleText!, textAlign: TextAlign.center):content!,
                        if(!empty(onConfirm) || !empty(onCancel) || !empty(onCustom) || !empty(actions))Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if(!empty(onCancel))ButtonFlat(
                                onPressed: (){
                                  onCancel!();
                                  appNavigator.pop();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.grey.withOpacity(0.3))
                                ),
                                child: Text(lang(textCancel??'Huỷ')),
                                // style: TextButton.styleFrom(
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(18.0),
                                //     ),
                                // ),
                              ),
                              if(!empty(onConfirm) && !empty(onCancel))SizedBox(width: 20),
                              if(!empty(onConfirm))ElevatedButton(
                                onPressed: onConfirm,
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(currentContext).floatingActionButtonTheme.backgroundColor,
                                    onPrimary: Colors.white,
                                    textStyle: TextStyle(color: Colors.white),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    elevation: 0,
                                    onSurface: Colors.white
                                ),
                                child: Text(lang(textConfirm??'Đồng ý')),
                              ),
                              ...actions??[]
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      }
  );
}
showBottomMenu({
  Widget? child,
  Widget? bottom,
  dynamic title,
  String? fileName,
  Widget? actionRight,
  Widget? actionLeft,
  BottomSheetType? type,
  Color? backgroundColor,
  EdgeInsets? padding
})async{
  final _res = await appNavigator.bottomSheet(
    child: child,
    bottom: bottom,
    title: title,
    actionRight: actionRight,
    actionLeft: actionLeft,
    backgroundColor: backgroundColor,
    padding: padding,
    type: type,
  );
  return _res;
}
openFile(String file, {String? title,TextStyle? styleTitle, bool notDownload = false}){
  appNavigator.showFullDialog(child: ViewFilePage({
    'file': file,
    'title': title,
    'styleTitle': styleTitle,
    'hasDownloadFile': (notDownload)?false:!empty(factories['hasDownloadFile'])
  }));
}
String toRound(var data, [int places = 1]) {
  double? mod = parseDouble(pow(10.0, places));
  final double _res = ((data.toString().parseDouble() * mod).round().toDouble() / mod);
  if (_res.toString().lastIndexOf('.0') + 2 == _res.toString().length) {
    return _res.ceil().toString();
  }
  return _res.toString();
}

extension StringToRound on String{
  String toRound([int places = 1]) {
    double? mod = parseDouble(pow(10.0, places));
    final double _res = ((this.parseDouble() * mod)
        .round()
        .toDouble() / mod);
    if (_res.toString().lastIndexOf('.0') + 2 == _res
        .toString()
        .length) {
      return _res.ceil().toString();
    }
    return _res.toString();
  }
}

showFilter<T extends GetxController>({@required Widget Function(T controller)? childBuilder,
  String? tagController, Function? onSearch, Function? onCancel, String? title}) async{
    final controller = Get.find<T>(tag: tagController);
    return await showBottomMenu(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          GetBuilder<T>(
            tag: tagController,
            builder: (_controller){
              if(childBuilder != null)return childBuilder(controller);
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(currentContext).floatingActionButtonTheme.backgroundColor),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
                ),
                onPressed: () {
                  if(onSearch != null)onSearch();
                  appNavigator.pop('onSearch');
                },
                child: Text('Áp dụng'.lang())),
          ),
        ],
      ),
      actionLeft: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          appNavigator.pop();
        },
      ),
      actionRight: (onCancel != null)
          ? TextButton(
            onPressed:(){
              onCancel();
              // appNavigator.pop('onCancel');
            },
            child:Text( 'Xóa'.lang(), maxLines: 1)
          )
        : null,
    title: '${title ?? 'Bộ lọc'}'.lang());
}
Future<String> getAssetFilePath(AssetEntity? asset)async{
  final File? file = await asset!.file;
  return file!.path;
}
String getFileName(String path){
  return path.substring(path.lastIndexOf('/') + 1);
}