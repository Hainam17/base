import 'dart:developer';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import '../global.dart';
import '../helper.dart';
import 'PermissionLib.dart';

dioCacheSupport(){
  return (Platform.isIOS || Platform.isAndroid || Platform.isMacOS);
}

class _DioHelper {
  static Dio? _dio;
  static DioCacheManager? _manager;
  static PersistCookieJar? cookieJar;

  static Future<List<Cookie>> getCookie()async{
    if(isWeb){
      return <Cookie>[];
    }
    return await cookieJar!.loadForRequest(Uri.parse(app['domain'] + "/"));
  }

  static Dio? getDio() {
    if (null == _dio) {
      if(!isWeb) {
        cookieJar = PersistCookieJar(
            ignoreExpires: true,
            storage: FileStorage(appDocumentDirectory!.path + "/.cookies/")
        );
      }
      _dio = Dio()
        ..interceptors.add(getCacheManager()!.interceptor);
      if(!isWeb) {
        _dio!.interceptors.add(CookieManager(cookieJar!));
      }
      getCsrfToken();
    }
    if(!isWeb) {
      (_dio!.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.findProxy = (uri) {
    //     //proxy all request to localhost:8888
    //     return "PROXY 10.61.185.20:8888";
    //   };
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    // };
    return _dio;
  }

  static DioCacheManager? getCacheManager() {
    if (null == _manager) {
      _manager = DioCacheManager(CacheConfig());
    }
    return _manager;
  }

  static reset(){
    _dio!.close(force: false);
    _dio = null;
  }

  static getCsrfToken() async{
    if(!isWeb) {
      List<Cookie> results =
          await getCookie();

      results.forEach((element) {
        if (element.name == 'AUTH_BEARER_default') {
          List _d = element.value.split('\.');
          if(_d.length > 1) {
            String data = jsonDecode(utf8.decode(base64
                .decode(base64.normalize(_d[1]))))['data'];
            if (data.length > 0) {
              data.split(';').forEach((element) {
                if (element.split('|')[0] == 'csrfToken') {
                  csrfToken = element.substring(element.indexOf('"'));
                  csrfToken = csrfToken.substring(1, csrfToken.length - 1);
                }
              });
            }
          }
        }
        if (element.name == 'be') {
          log('Server: ${element.value}');
        }
      });
    }
  }

  clearCacheAll() async {
    if(dioCacheSupport()) {
      await _manager!.clearAll();
    }
  }
  clearCache(String url,{Map<String, dynamic>? params})async{
    if(dioCacheSupport()) {
      final _url = '${app['domain']}/api/' + url.replaceAll('.', '/');
      var _params = <String, dynamic>{};
      _params.addAll(params ?? {});
      if (_params['site'] == null || _params['site'] == '') {
        _params['site'] = app['id'].toString();
      }
      _params['securityToken'] = csrfToken;
      await _manager!.deleteByPrimaryKeyAndSubKey(_url, requestMethod: "POST",
          subKey: (params != null) ? json.encode(_params) : null);
    }
  }

  static String convertDataToUrl(Map map, [String? field]) {
    String _url = '';
    map.forEach((key, value) {
      String _key = '$key';
      if(field != null){
        _key = '$field[$key]';
      }
      if(value is Map){
        _url += '${convertDataToUrl(value, _key)}';
      }else if(value is List){
        _url += '${_convertListToUrl(value, _key)}';
      }else if(value is String || value is num){
        _url += '&$_key=$value';
      }
    });
    return ((field == null && _url.startsWith('&'))?'?${_url.substring(1)}':_url);

  }
  static String _convertListToUrl(List data, String key){
    String _url = '';
    data.asMap().forEach((index, value){
      if(value is String || value is num){
        _url += '&$key[$index]=$value';
      }else if(value is List){
        _url += _convertListToUrl(value, '$key[$index]');
      }else if(value is Map){
        _url += '${convertDataToUrl(value, '$key[$index]')}';
      }
    });
    return _url;
  }
}

Future<List<Cookie>> getCookies()async{
  if(isWeb) {
    return <Cookie>[];
  }
  return await _DioHelper.getCookie();
}

Future download(String url,
    {String? savePath, String? fileName, bool toDownloadFolder = false, ValueNotifier<double>? process}) async {
  String _url = url;
  List<Permission> permissions = isWeb?[Permission.storage]:[Permission.storage, if(Platform.isIOS)Permission.photos, if(Platform.isIOS)Permission.mediaLibrary];
  final _res = await PermissionLib().requests(permissions);
  if(_res) {
    // if(Platform.isIOS)toDownloadFolder = false;
    if (savePath == null) {
      if(toDownloadFolder) {
        // Directory? _downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
        // String _fileName = url.substring(url.lastIndexOf('/') + 1);
        // if(fileName != null){
        //   _fileName = fileName;
        // }
        savePath = await getDownloadDir(url);
      }else{
        var tempDir = await getApplicationDocumentsDirectory();
        String _fileName = !empty(fileName)?fileName!:url.substring(url.lastIndexOf('/') + 1);
        if (url.indexOf('upload/') == 0)
          _fileName = url.substring(url.indexOf('/', 7) + 1).replaceAll('/', '-');
        if(fileName != null){
          _fileName = fileName;
        }
        savePath = tempDir.path +'/'+ _fileName;
      }
    }
    if (url.indexOf('upload/') == 0) _url = urlConvert(url);
    final _dio = _DioHelper.getDio();
    try {
      Response response = await _dio!.get(
        _url,
        onReceiveProgress: (received, total) {
          log('${received / total}');
          if (process != null) {
            process.value = received / total;
          }
        },
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return savePath;
    } catch (e) {
      log('$e');
    }
  }else{
    showMessage('Bạn vui lòng cấp quyền truy cập bộ nhớ để thực hiện được tính năng này!');
  }
}

Future<Map?> upload(String filePath,
    {String? fileName, ValueNotifier<double>? process}) async {
  final _dio = _DioHelper.getDio();
  final int _time = (new DateTime.now()).millisecondsSinceEpoch;
  log('upload: $filePath');
  final MultipartFile _file =
      MultipartFile.fromFileSync(filePath, filename: fileName);
  Map<String, dynamic> _params = {
    if(!empty(app['id'], true))'site': app['id'],
    'securityToken': csrfToken,
    'qqfile': _file
  };
  FormData _formData = new FormData.fromMap(_params);
  try {
    final _res = await _dio!.post(
      '${app['domain']}/qqupload.php',
      options: Options(
        sendTimeout: 0
      ),
      data: _formData,
      onSendProgress: (int sent, int total) {
        if (process != null) {
          process.value = sent / total;
        }
      },
    );
    log('StartAPI (${((new DateTime.now()).millisecondsSinceEpoch - _time)/1000}s) ${app['domain']}/qqupload.php');
    log('data: ($_params)');
    log('response: ${_res.data} End API');
    if (_res.statusCode == 200) {
      return json.decode(_res.data);
    }
  } catch (e) {
    log('$e');
  }
  return null;
}

dynamic post(String url,
    {Map<String, dynamic>? params,
    Duration? cacheTime,
    Duration? maxStale,
    DioOptions? options,
    bool isRetry = false,
      String method = '',
    bool? forceRefresh}) async {
  final int _time = (new DateTime.now()).millisecondsSinceEpoch;
  final _dio = _DioHelper.getDio();
  var _params = params ?? {};

  try {
    if(url.startsWith('http')) {
      var retryCount = 1;
      bool flag = true;
      while(flag) {
        if(retryCount >= 5)flag = false;
        FormData _formData = new FormData.fromMap(_params);
        var _res;
        if(url.contains('selectAll')){
          _res = await _dio!.get(url,
              queryParameters: _params,
              options: (cacheTime != null)
                  ? buildCacheOptions(cacheTime,
                  primaryKey: url,
                  subKey: json.encode(_params),
                  maxStale: maxStale ?? const Duration(days: 30),
                  options: _convertOption(options ?? null),
                  forceRefresh: forceRefresh ?? true)
                  : null);
        }else{
          _res = await _dio!.post(url,
              data: _formData,
              options: (cacheTime != null)
                  ? buildCacheOptions(cacheTime,
                  primaryKey: url,
                  subKey: json.encode(_params),
                  maxStale: maxStale ?? const Duration(days: 30),
                  options: _convertOption(options ?? null),
                  forceRefresh: forceRefresh ?? true)
                  : null);
        }
        print('response.headers.map[set-cookie]----${_res.headers.map}');
        log(
            'StartAPI $url${_DioHelper.convertDataToUrl(_params)}');
        log('data: ($_params)');
        log('(${'${(method.toLowerCase() == 'post' || _params.toString().length > 2000
            || new RegExp('/edit|/delete|/update|/change').hasMatch(url))?'POST':'GET'}(${((new DateTime.now()).millisecondsSinceEpoch - _time) /
            1000}s)  $url'})response: ${_res.data} End API');
        if (_res.statusCode == 200 && (!isRetry || !empty(_res.data))) {
          _DioHelper.getCsrfToken();
          return _res.data;
        } else if (isRetry && retryCount++ < 5 && (_res.statusCode != 200 || _res.data == '')) {
          if(_res.statusCode == 302 && url.startsWith(app['domain'])){
            _DioHelper.reset();
            await Future.delayed(Duration(seconds: 1));
            return await post(url,params: params,cacheTime: cacheTime,maxStale: maxStale,
                options: options,isRetry: false,method: method,forceRefresh: forceRefresh);
          }
          await Future.delayed( const Duration(seconds: 3));
        }else{
          break;
        }
      }
    }else{
      log('$app-----$url');
    }
  } catch (e) {
    log('StartAPI (${((new DateTime.now()).millisecondsSinceEpoch - _time)/1000}s)  $url${_DioHelper.convertDataToUrl(_params)}');
    log(_params.toString());
    log(e.toString());
    if(isRetry) {
      _DioHelper.reset();
      await Future.delayed(Duration(seconds: 2));
      return await post(url, params: params,
        cacheTime: cacheTime,
        maxStale: maxStale,
        options: options,
        isRetry: false,
        method: method,
        forceRefresh: forceRefresh
      );
    }

  }
}

dynamic call(
  String? serviceName, {
  Map? params,
  Duration? cacheTime,
  Duration? maxStale,
  DioOptions? options,
  bool hasSite = true,
  bool? forceRefresh = true,
      bool? isRetry = false,
}) async {
  if(serviceName == null)return null;
  final _url = '${app['domain']}/api/' + serviceName.replaceAll('.', '/');
  Map<String, dynamic> _params = {};
  if(params != null) {
    _params.addAll(Map<String, dynamic>.from(params));
  }
  if ((_params['site'] == null || _params['site'] == '') && !empty(app['id'])) {
    if(hasSite){
      _params['site'] = app['id'].toString();
    }else{
      if(!empty(_params['rootSiteId'])){
        _params['site'] = _params['rootSiteId'].toString();
      }else  if(!empty(factories['rootSiteId'])){
        _params['site'] = factories['rootSiteId'].toString();
      }
    }
  }
  if(!empty(factories['groupId'])){
    _params['groupId'] = factories['groupId'];
  }
  if(!empty(factories['appVersion'])){
    _params['appVersion'] = factories['appVersion'];
  }
  if(!empty(factories['setClientLanguage']) && !_params.containsKey('setClientLanguage')){
    _params['setClientLanguage'] = factories['setClientLanguage'];

    //setClientLanguage = '';
  }
  if(isWeb){
    _params['OS'] = 'onWeb';
  }else{
    if(Platform.isIOS){
      _params['OS'] = 'IOS';
    }
    if(Platform.isAndroid){
      _params['OS'] = 'Android';
    }
    if(Platform.isWindows){
      _params['OS'] = 'Windows';
    }
    if(Platform.isLinux){
      _params['OS'] = 'Linux';
    }
  }

  if(_params.containsKey('callbackFunction')){
    _params.remove('callbackFunction');
  }
  _params['securityToken'] = csrfToken;
  final res = await post(_url,
    params: _params,
    cacheTime: dioCacheSupport()?cacheTime:null,
    maxStale: maxStale,
    options: options,
    isRetry: isRetry??false,
    forceRefresh: dioCacheSupport()?(forceRefresh??true):true,
  );
  final _res = (res is String)?res.trim():res;
  if (_res != null && _res != '') {
    if (_res is String && RegExp(r'^\w+$').hasMatch(_res)) {
      return _res;
    }
    if(_res is String && !((_res.trim().startsWith('{') && _res.trim().endsWith('}'))
        || (_res.trim().startsWith('[') && _res.trim().endsWith(']')))){
      if(_res.contains('Access denied! Privilege error: member -> Require login') || _res.contains('Require login')
      || (_res.startsWith('Redirect to:') && _res.contains('page=login'))){
        if(serviceName != 'Member.User.logout') {
          await logout();
        }
        return null;
      }else {
        return _res;
      }
    }
    try {
      if(_res is String) {
        if(_res.contains('Access denied! Privilege error: member -> Require login')){
          if(serviceName != 'Member.User.logout') {
            await logout();
          }
          return null;
        }else if(_res.contains('Require login')){
          if(serviceName != 'Member.User.logout') {
            await logout();
          }
          return null;
        }
        else{
          final data = jsonDecode(_res);
          if (data is Map && data['status'] == 'expired') {
            appFound(data);
          }
          if (data is Map && data['status'] == 'FAIL' && data['message'] == 'Require login') {
            if(serviceName != 'Member.User.logout') {
              await logout();
            }
            return null;
          }
          if(data == null){
            return _res;
          }
          return data;
        }
      }
      if(_res is Map){
        if ( _res['status'] == 'expired') {
          appFound(_res);
        }
        if (_res['status'] == 'FAIL' && _res['message'] == 'Require login') {
          if(serviceName != 'Member.User.logout') {
            await logout();
          }
          return null;
        }
      }

      return _res;
    } catch (e) {}
  }
}
clearAllCache() async {
  await _DioHelper().clearCacheAll();
}
clearCache(String url,{Map<String, dynamic>? params})async{
 await _DioHelper().clearCache(url, params: params);
}
class DioOptions{
  final String? method;
  ///miliseconds
  final int? sendTimeout;
  ///miliseconds
  final int? receiveTimeout;
  final Map<String, dynamic>? extra;
  final Map<String, dynamic>? headers;
  final ResponseType? responseType;
  final String? contentType;
  final ValidateStatus? validateStatus;
  final bool? receiveDataWhenStatusError;
  final bool? followRedirects;
  final int? maxRedirects;
  final RequestEncoder? requestEncoder;
  final ResponseDecoder? responseDecoder;
  final ListFormat? listFormat;
  const DioOptions({this.method, this.sendTimeout, this.receiveTimeout,
  this.extra, this.headers, this.responseType, this.contentType, this.validateStatus,
  this.receiveDataWhenStatusError, this.followRedirects, this.maxRedirects,
  this.requestEncoder, this.responseDecoder, this.listFormat});
}
Options? _convertOption([DioOptions? options]){
  if(options is DioOptions) {
    return Options(
      method: options.method,
      sendTimeout: options.sendTimeout,
      receiveTimeout: options.receiveTimeout,
      extra: options.extra,
      headers: options.headers,
      responseType: options.responseType,
      contentType: options.contentType,
      validateStatus: options.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
      followRedirects: options.followRedirects,
      maxRedirects: options.maxRedirects,
      requestEncoder: options.requestEncoder,
      responseDecoder: options.responseDecoder,
      listFormat: options.listFormat,
    );
  }
  return null;
}
