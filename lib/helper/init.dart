import 'package:flutter/material.dart';
import 'package:vhv_basic/helper/theme.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/libs/AccountLib.dart';
accountGetDataInit(Map? _accountData) async {
  var userId = _accountData?['id'];
  if (userId != null && userId != '' && userId != 0 && _accountData is Map) {
    account.assign(_accountData, true);
  } else {
    account.assign(
        {'id': 0, 'fullName': 'Guest', 'code': '', 'email': '', 'phone': ''});
  }
}
_logOut([bool noRedirect = false]) async {
  showLoading();
  if(Setting().containsKey('hasChangePassword')) {
    await Setting().delete('hasChangePassword');
  }
  if(empty(factories['logOuting'])) {
    factories['logOuting'] = 1;
    factories.remove('appStatus');
    factories.remove('appFoundRouter');
    await account.logOut();
    if (Setting('Config').containsKey('site')) {
      await Setting('Config').delete('site');
    }
    app['id'] = factories['rootSiteId'];
    await clearAllCache();
    if (afterLogout != null) await afterLogout!();
    if (factories['logoutFunctions'] != null) {
      factories['logoutFunctions'].forEach((func) {
        func();
      });
    }
    Future.delayed(const Duration(seconds: 2),(){
      factories.remove('logOuting');
    });
    if (!noRedirect) {
      String _route =
      (factories['loginFeature'] == LoginOption.required)
          ? '/Account/Login'
          : (factories['initialPage'] ?? '/Home');
      appNavigator.pushNamedAndRemoveAllUntil(_route);
    }
  }
  disableLoading();
}

accountGetData(LoginOption login) async {
  Map _accountData = Setting('Config').get('account');
  account = new AccountLib();
  var userId = Setting('Config').get('userId');
  if (userId != null && userId != '' && userId != 0) {
    if (_accountData['id'] == userId) {
      account.assign(_accountData, false);
      _getNewAccountInfo();
    } else {
      await _getNewAccountInfo();
    }
  } else {
    account.assign(
        {'id': 0, 'fullName': 'Guest', 'code': '', 'email': '', 'phone': ''});
  }
}

_getNewAccountInfo() async {
  if(!empty(csrfToken)){
    Map _accountData = Setting('Config').get('account');
    if(account.isLogin()) {
      final _account = await call('Member.User.getData');
      if (_account != null && _account is Map) {
        if(factories['updateAccountCallback'] != null){
          factories['updateAccountCallback'](_account);
        }
        final bool _put = ((_accountData['lastUpdateTime'] == null) ||
            (_accountData['lastUpdateTime'] < _account['lastUpdateTime'] ?? 0));
        await account.assign(_account, _put);
      }else if(_account is String && _account == 'NOTLOGIN'){
        await call('Member.User.logSessionForTest', params: {
          'oldUser': account.getData()
        });
        showMessage('Phiên đăng nhập của bạn đã kết thúc!'.lang());
        await Future.delayed(const Duration(seconds: 2),(){
          _logOut();
        });
      }
    }
  }else{
    Future.delayed(const Duration(seconds: 3),(){
      _getNewAccountInfo();
    });
  }
}
_login(Map response)async{
  print('response-----------${response['account']}');
  await account.assign(response['account'], true, false);
  if(!empty(response['siteDomain']))app['siteDomain'] = response['siteDomain'];
  await Setting('Config').put('userId', account['id']);
//  sendDeviceId();
  Get.find<AppLib>().getAppInfo();
}

appLibInit(Map? accountData, [bool isInit = false]) async {
  if(isInit) {
    account = new AccountLib();
  }
  await accountGetDataInit(accountData);
  if(account.isLogin()){
    final Map? _site = Setting('Config').get('site');
    if (!empty(_site) && _site is Map) {
      if (!empty(_site['id'])) app['id'] = _site['id'];
      if (!empty(_site['title'])) app['title'] = _site['title'];
    }
  }
  String? _saveTheme = (Setting('Config').get('theme')) ?? 'system';

  currentTheme =
  (_saveTheme != null) ? themeConvert(_saveTheme) : ThemeMode.system;
  if(!empty(Setting('Config').get('hasChangePassword'))){
    await Setting('Config').delete('hasChangePassword');
    _logOut();
  }
  logout = ()async{
    await _logOut();
  };
  login = (Map response,[bool hasNavigation = true])async{
    print('login-----------------1');
    await clearAllCache();
    print('login-----------------2');
    if(factories['loginSuccess'] != null)await Future.forEach(factories['loginSuccess']!, (Function element)async{
      await element(response);
    });
    print('login-----------------3');

    await _login(response);
    if(hasNavigation) {
      goToHome();
    }
  };
}