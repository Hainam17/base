import 'package:flutter/cupertino.dart';
import 'package:vhv_basic/import.dart';

class AccountNotificationDetailController extends ChangeNotifier{
  final String id;
  AccountNotificationDetailController(this.id){
    select();
  }
  Map params = new Map();
  bool isHide = false;
  select() async{
    final _res = await call('Member.Notification.select', params: {
      'id': id
    });
    if(_res != null){
      if(_res['users'] != null && (_res['users'].indexOf(account['id']) >= 0 || _res['users'].indexOf(account['accountId']) >= 0 || (_res['isView'] != null && _res['isView'].toString().isNotEmpty))) {
        params = _res;
      }else{
        isHide = true;
      }
      notifyListeners();
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
}