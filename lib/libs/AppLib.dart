import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/helper/init.dart';
import 'package:vhv_basic/widgets/InAppUpdate.dart';
import 'package:vhv_basic/widgets/Maintenance.dart';
import '../global.dart';
import 'DioLib.dart';
import 'NavigatorLib.dart';
import 'package:vhv_basic/libs/SettingLib.dart';


class AppLib extends GetxController {
  bool _hasUpdate = false;
  bool get hasUpdate => _hasUpdate;
  ConnectivityResult? _connectivityResult;
  late ValueNotifier<Map> appInfo;
  
  

  @override
  onInit(){
    appInfo = ValueNotifier(Setting().get('site')??{});
    _init();
    return super.onInit();
  }

  _init()async{
    final _res = await Connectivity().checkConnectivity();
    if(_res == ConnectivityResult.none){
      _showAlertDialog();
    }
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print('result------------------$result');
      if(_connectivityResult != result){
        _connectivityResult = result;
        connectionStatus = _getStatusFromResult(result);
        if(_connectivityResult != null){
          if(_connectivityResult == ConnectivityResult.none){
            _showAlertDialog();
          }else{
            cancelAllMessage();
          }
          update();
        }
      }
    });
    if(Setting('Config').containsKey('groupId')){
      factories['groupId'] = Setting('Config').get('groupId');
    }
    appNavigator = NavigatorLib();
    getAppInfo();
    _getAllTitle();
    appRefresh = (){
      update();
    };
  }
  
  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.wifi;
      case ConnectivityResult.none:
        return ConnectivityStatus.offline;
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.ethernet;
      case ConnectivityResult.bluetooth:
        return ConnectivityStatus.bluetooth;
      default:
        return ConnectivityStatus.offline;
    }
  }
  
  void _showAlertDialog() {
    if(!empty(factories['showConnectionWarning'])){
      FocusScope.of(currentContext).requestFocus(new FocusNode());
      BotToast.showAnimationWidget(
          onlyOne: true,
          allowClick: false,
          backgroundColor: Colors.black.withOpacity(0.4),
          backButtonBehavior: BackButtonBehavior.none,
          toastBuilder: (cancelFunc) => Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                constraints: BoxConstraints(
                  maxWidth: 220
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                          child: Image.asset('assets/images/ic_not_connected.PNG',
                            package: 'vhv_basic',
                            height: 100,
                          )
                      ),
                      const SizedBox(height: 10,),
                      Text(lang('Rất tiếc'), style: Theme.of(currentContext).textTheme.headline6),
                      const SizedBox(height: 10,),
                      Text(
                        lang('Thiết bị của bạn có thể đang mất kết nối,\n vui lòng hãy kiểm tra lại mạng!'),
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        children: [
                          Spacer(),
                          TextButton(
                            child: Text(lang('Đã hiểu')),
                            onPressed: (){
                              cancelFunc();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
                // actions: <Widget>[
                //   TextButton(
                //     child: Text(lang('Đã hiểu')),
                //     onPressed: (){
                //       cancelFunc();
                //     },
                //   )
                // ],
              ),
            )
          ),
          animationDuration: Duration(milliseconds: 300)
      );
    }
  }
  
  getAppInfo([bool hasRetry = true])async{
    if(Setting().containsKey('site')){
      app['siteDomain'] = Setting().get('site')['domain'];
    }
    final String? token = Setting('Config').get('tokenPushNotification');
    PackageInfo packageInfo = await getPackageInfo();
    String version = packageInfo.version;
    factories['appVersion'] = version;
    final _date = new DateTime.now();
    factories['deviceId'] = !empty(token)?token:'mobile';
    final _res = await call('CMS.Application.getInfo', params: {
      'setClientLanguage': currentLanguage,
      'deviceId': !empty(token)?token:'mobile',
      'appVersion': version,
      'appBundleId': packageInfo.packageName,
      if(!empty(factories['notShowUpdate']))'notShowUpdate': 1,
      if(!empty(factories['menuType']))'menuType': factories['menuType']
    });
    if(!empty(_res) && _res is Map){
      if(!empty(_res['systemMaintenance'])){
        appNavigator.pushAndRemoveAllUntil(() => Maintenance(message: _res['systemMaintenance'],));
      }else{
        if(_res['userData'] is Map){
          appLibInit(_res['userData']);
        }
        if(setupData != null){
          setupData!(_res);
        }
        if(!empty(_res['serverTime'])){
          //Check gio server
          await checkServerTime(_res['serverTime'], _date);
        }
        Setting().put('getInfoTime', time());
        if(!empty(_res['id'])) {
          if (!empty(_res['currency'])) {
            factories['currency'] = _res['currency'];
          }
          if (!empty(_res['shortCurrency'])) {
            factories['shortCurrency'] = _res['shortCurrency'];
          }
          _checkUpdate(_res);
          if (!empty(_res['staticDomain'])) {
            app['staticDomain'] = _res['staticDomain'];
          } else {
            app['staticDomain'] = app['domain'];
          }
          if (!empty(_res['domain'])) {
            app['siteDomain'] = _res['domain'];
          }
          if (!empty(_res['image'])) app['logo'] = _res['image'];
          _res..removeWhere((key, value) => (value is IconData || key is IconData));
          appInfo.value = {}..addAll(_res);
          await Setting('Config').put('site', _res);

          if (_res['alert'] is Map) {
            Map alert = _res['alert'];
            appNavigator.showDialog(
                title: alert['title'] ?? 'Thông báo',
                middleText: (alert['content'] != null) ? alert['content'] : null,
                textCancel: alert['textCancel'],
                textConfirm: alert['textConfirm'] ?? 'Đồng ý',
                confirmTextColor: Colors.white,
                onCancel: !empty(alert['textCancel']) ? () {
                  appNavigator.pop();
                } : null,
                barrierDismissible: empty(alert['notDismiss']),
                onConfirm: () {
                  appNavigator.pop();
                  if (alert['router'] != null) {
                    String? link;
                    if (alert['router'] is Map) {
                      String? key;
                      if(isWeb) {
                        key = 'web';
                      }else{
                        if (Platform.isIOS) key = 'ios';
                        if (Platform.isAndroid) key = 'android';
                        if (Platform.isFuchsia) key = 'fuchsia';
                        if (Platform.isWindows) key = 'windows';
                      }
                      if (alert['router'].containsKey(key)) {
                        link = alert['router'][key];
                      }
                    } else if (alert['router'] is String) {
                      link = alert['router'];
                    }
                    if (link!.startsWith('/')) {
                      appNavigator.pushNamed(link, arguments: alert['params']);
                    } else if (link.startsWith('http')) {
                      urlLaunch(link, forceWebView: !empty(alert['useWebView']));
                    }
                  }
                }
            );
          }
        }else{
          Future.delayed(const Duration(seconds: 2),(){
            appFound(_res);
          });
        }
        appRefresh!();
      }

    }else{
      if(hasRetry) {
        Future.delayed(const Duration(seconds: 5), () {
          getAppInfo(false);
        });
      }
    }
  }
  _checkUpdate(Map appInfo)async{
    PackageInfo packageInfo = await getPackageInfo();
    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String platform = isWeb?'web':(Platform.isIOS?'ios':'android');
    if(!empty(appInfo['appInfo'])){
      Map _appInfo = (appInfo['appInfo'] is String)?json.decode(appInfo['appInfo']):((appInfo['appInfo'] is Map)?appInfo['appInfo']:{});
      if(!empty(_appInfo) && !empty(_appInfo[platform])) {
        Map _newVer = _appInfo[platform];
        List _news = _newVer['version'].split('.');
        List _olds = version.split('.');
        int _index = 0;
        bool _hasNew = false;
        _news.forEach((element) {
          int _new = element.toString().parseInt();
          int _old = (_olds.length > _index)?_olds[_index].toString().parseInt():0;
          if(_new > _old){
            _hasNew = true;
          }
          _index++;
        });
        if (_hasNew || (_newVer['version'] == version && (_newVer['buildNumber'].toString().parseInt() > buildNumber.toString().parseInt()))) {
          Future.delayed(const Duration(seconds: 5), () {
            appNavigator.dialog(
                Dialog(
                  child: InAppUpdate({
                    'appName': appName,
                    'link': _newVer['link'],
                    'current': {
                      'version': version,
                      'buildNumber': buildNumber
                    },
                    'new': {
                      'version': _newVer['version'],
                      'buildNumber': _newVer['buildNumber']
                    }
                  }),
                ),
                barrierDismissible: false
            );
          });
        }
      }
    }
  }

  _getAllTitle()async{
    List<String> _hasCall = [];
    final _services = Setting('Config').get('serviceGetAllTitles');
    if(!empty(_services) && _services is Map){
      Future.forEach(_services.entries, (MapEntry entry)async{
        Map<String, dynamic>? _params;
        if(!empty(entry.value) && entry.value is Map){
          _params = {};
          entry.value.forEach((k, v){
            _params!['$k'] = v;
          });
        }
        if(entry.key.toString().indexOf('-') != -1){
          String _service = entry.key.toString().substring(0, entry.key.toString().lastIndexOf('-'));
          if(!_hasCall.contains(_service)) {
            _hasCall.add(_service);
            final _res = await call(entry.key.toString().substring(
                0, entry.key.toString().lastIndexOf('-')), params: _params);
            if (!empty(_res)) {
              final List _data = (_res is List) ? _res : (!empty(_res['items'])
                  ? (_res['items'] is Map)
                  ? (_res['items'].values.toList())
                  : _res['items']
                  : []);
              Map<String, Map> _items = {};
              _data.forEach((element) {
                _items['${element['id'] ?? element['code']}'] = {
                  '$currentLanguage': element['label'] ?? element['title']
                };
              });
              final _old = Setting('Config').get('${entry.key}');
              if (!empty(_old) && _old is Map) {
                _old.forEach((k,v) {
                  _items.addAll({
                    '$k': ((!empty(v) && v is Map)?(v..addAll((_items['$k']??{}))):_items['$k']) as Map<String, dynamic>
                  });
                });
              }
              Setting('Config').put('$_service', _items);
            }
          }
        }});
    }
  }


  selectAllNotification([String? service]) async {
    final _res = await call(service??'Member.Notification.selectAll');
    if (_res is Map) {
      return _res;
    }
    return {};
  }
}
