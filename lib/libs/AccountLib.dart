import 'package:vhv_basic/import.dart';

class AccountLib {
  Map data = new Map();
  dynamic operator [](String name) {
    if (data.containsKey(name)) {
      return data[name];
    }
    return null;
  }

  void operator []=(String name, value) {
    data[name] = value;
    Setting('Config').put('account', data);
  }

  bool isLogin() {
    return data.containsKey('id') && !empty(data['id']);
  }
  bool isAdmin(){
    return data.containsKey('isAdmin') && !empty(data['isAdmin']);
  }

 bool isOwner(){
    return data.containsKey('isOwner') && !empty(data['isOwner']);
  }

  assign(accountData, [putSetting = true, bool hasRefresh = true]) async {
    data = accountData;
    if (putSetting) {
      await Setting('Config').put('account', data);
      if(appRefresh != null && hasRefresh){
        appRefresh!();
      }
    }
  }
  logOut() async {
    await Setting('Config').delete('account');
    await Setting('Config').delete('userId');
    await Setting('Config').delete('site');
    await call('Member.User.logout');
    app['id'] = factories['rootSiteId'];
    data = {};
  }

  Map getData() {
    return {}..addAll(data);
  }
}
