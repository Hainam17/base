import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vhv_basic/import.dart';
import 'LoginForm/src/models/login_data.dart';

class AuthController extends GetxController{
  final showLoginCaptcha = false.obs;
  final captchaMessage = ''.obs;

  bool hasLogin = false;
  @override
  onInit(){
    if(!empty(factories['loginUsernameTitle'])){
      _title = factories['loginUsernameTitle'];
    }
    super.onInit();
  }
  Function? extraValidLogin;
  Map<String, dynamic> extraDatas = {};
  VoidCallback? reloadCaptcha;

  var rule = false.obs;
  var ruleMessage = ''.obs;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  String agree = '';
  void setRule(val) {
    rule.value = val;
    agree = val ? 'agree' : '';
  }

  String _title = 'Tài khoản';
  Map<String, String> _captcha = <String, String>{};
  dynamic validUsername(String value, [bool isLogin = true]) {
    if (value.isEmpty) {
      return 'Bạn chưa nhập ${_title.toLowerCase()}.'.lang();
    }
    if (!isLogin && !value.isEmail) {
      return '$_title không đúng định dạng'.lang();
    }
  }

  dynamic validFullName(String value) {
    if (value.isEmpty) {
      return 'Tên người dùng không được để trống.'.lang();
    } else if (value.length > 100) {
      return 'Tên người dùng không được quá ký tự.'.lang(args: ['100']);
    }
  }

  dynamic validPassword(String value) {
    if (value.isEmpty) {
      return 'Bạn chưa nhập mật khẩu.'.lang();
    }
  }

  String _password = '';

  _login(LoginData loginData) async {
    _password = loginData.password!;
    return await call('Member.User.login', params: {
      'fields': <String, dynamic>{
        'username': loginData.name,
        'password': loginData.password,
        'loginType': 'app',
      },
      if(showLoginCaptcha.value == true)'captcha_code': _captcha['captcha_code'],
      'remember': '1',
    }..addAll(extraDatas));
  }
  bool hasCaptcha = false;
  Future<dynamic> submit(LoginData loginData) async {
    if(extraValidLogin == null || extraValidLogin!() == null) {
      captchaMessage.value = '';
      if(!hasCaptcha || (!empty(_captcha) && !empty(_captcha['captcha_code']))){
        var _res = await _login(loginData);
        if (_res == null) {
          _res = await _login(loginData);
        }
        if (_res != null) {
          if (_res is Map && !empty(_res['error']) &&
              _res['error'].toString().indexOf('Token') != -1) {
            await Future.delayed(Duration(seconds: 1));
            _res = await _login(loginData);
          }
          if (_res is String && _res.indexOf('error') != -1 &&
              _res.indexOf('Token') != -1) {
            await Future.delayed(Duration(seconds: 1));
            _res = await _login(loginData);
          }
          if (_res is String) _res = {'status': _res};
          if(_res is Map && ((!empty(_res['siteStatus'], true) && _res['siteStatus'].toString() != '1') || (!empty(_res['siteExpiredTime']) && parseInt(_res['siteExpiredTime']) < time()))){
            showMessage(lang(!empty(factories['appFoundMessage'])?factories['appFoundMessage']:'Ứng dụng hết hạn sử dụng!'), timeShow: 10, type: 'warning');
            return false;
          }
          if (_res['status'] == 'BotDetect') {
            update();
            hasCaptcha = true;
            if (showLoginCaptcha.value == false) {
              showLoginCaptcha.value = true;
              return false;
            } else {
              if (reloadCaptcha != null) {
                reloadCaptcha!();
              }
              if (!empty(_captcha['captcha_code'])) {
                captchaMessage.value = 'Mã xác thực không chính xác.';
                return false;
              } else {
                captchaMessage.value = 'Bạn chưa nhập mã xác thực.';
                return false;
              }
            }
          }
          if (_res['status'] == 'SUCCESS' &&
              _res['account'] != null) {
            if(!empty(factories['rememberPass'])){
              Map loginAcc = {
                'username': loginData.name,
                'pass':stringToBase64.encode(loginData.password!),
                'image':_res['account']['image'],
                'fullName':_res['account']['fullName'],
                'isCurrent':'1'
              };
              Map loginUsers = Setting().get('loginUsers')??{};
              if(loginUsers.containsKey(loginData.name) && loginUsers[loginData.name].containsKey('isBiometric')){
                loginAcc.addAll({
                  'isBiometric': '1'
                });
              }
              loginUsers.addAll({
                loginData.name:loginAcc
              });
              loginUsers.forEach((key, value) {
                if(!empty(value['isCurrent']) && key != loginData.name){
                  value.remove('isCurrent');
                }
              });
              Setting().put('loginUsers', loginUsers);
            }
            await _loginSuccess(_res);
          } else {
            if (reloadCaptcha != null) {
              reloadCaptcha!();
            }
          }
        }
        if (_res == null) {
          _res = {'status': 'FAIL', 'message': 'Có lỗi xảy ra.'.lang()};
        }
        if (_res['message'] == null || _res['message'] == '') {
          if (_res['status'] != null && _res['status'] != 'SUCCESS') {
            switch (_res['status']) {
              case 'ONEBYONE':
                _res['message'] =
                    '$_title của bạn đang đăng nhập trên hệ thống, vui lòng đăng nhập lúc khác!'
                        .lang();
                break;
              case 'USER_NOT_EXIST':
                _res['message'] = '$_title không tồn tại.'.lang();
                break;
              case 'FAIL':
                _res['message'] =
                    'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập!'
                        .lang();
                break;
              case 'BANNED':
                _res['message'] = '$_title của bạn đã bị khóa.'.lang();
                break;
              case 'LOCKED':
                _res['message'] = '$_title của bạn đã bị khóa tạm thời.'.lang();
                break;
              case 'TRY_BLOCK':
                _res['message'] =
                    '$_title đã bị khóa tạm thời do đăng nhập sai 5 lần liên tiếp.'
                        .lang();
                break;
              case 'WRONG_PASSWORD':
                _res['message'] = 'Sai mật khẩu.'.lang();
                break;
              default:
                _res['message'] = 'Có lỗi xảy ra.'.lang();
            }
            _res['status'] = 'FAIL';
          }
        }
        onFail(_res['message']);
        return _res['message'];
      }else{
        showLoginCaptcha.value = true;
        captchaMessage.value = 'Bạn chưa nhập mã xác thực.';
        update();
        return false;

      }
    }else{
      showMessage(extraValidLogin!(),type: 'FAIL');
      return extraValidLogin!();
    }
  }

  String birthDate = '';
  String phone = '';
  String get captcha => ((_captcha is Map)?(_captcha['captcha_code']??''):'');
  set captcha(String captcha) {
    if(!empty(captchaMessage.value)){
      captchaMessage.value = '';
    }
    _captcha.addAll({
      'captcha_code': captcha
    });
  }
  _loginSuccess(Map response)async{
    if(!empty(response['account'])) {
      hasLogin = true;
      await login(response, false);
      if(factories['loginMessage'] != null && factories['loginMessage'] is Function) factories['loginMessage'](response);
    }
    onSuccess(response);
  }

  onSuccess(Map response){
    if(!empty(factories['checkPasswordDefault'])){
      _checkPassDefault();
    }
  }
  _checkPassDefault(){
    final _res = call('CMS.Account.checkPasswordDefault', params: {
      'password': _password
    });
    if(!empty(_res) && _res.toString() == '1'){
      Setting().put('isPasswordDefault', '1');
    }else{
      Setting().delete('isPasswordDefault');
    }
  }
  onFail(String? message){

  }
  Future<String?> register(LoginData registerData) async {
    String _message;
    Map<String, String> _data = {
      'email': registerData.name!,
      'fullName': registerData.fullName!,
      'password': registerData.password!,
      'confirmPassword': registerData.password!,
      if(!empty(birthDate))'birthDate': birthDate,
      if(!empty(phone))'phone': phone,
      if(!empty(agree))'agree': agree,
    };
    _data.addAll(_captcha);
    final _res = await call('Member.User.register', params: _data);
    final String? _status = (_res is String) ? _res : _res['status'];
    if (_status != null) {
      if (_status == 'SUCCESS') {
        showMessage('Đăng ký thành công.'.lang(), type: 'SUCCESS');
        if (_res['status'] == 'SUCCESS' &&
            _res['account'] != null) {
          if(_res['account'] is Map && _res['account']['id'] != 'guest'){
            await _loginSuccess(_res);
          }
        }
        return null;
      } else if (_status == 'BotDetect') {
        if(reloadCaptcha != null){
          reloadCaptcha!();
        }
        _message = 'Bạn chưa nhập mã xác thực hoặc mã xác thực không đúng.'.lang();
        onFail(_message);
        return _message;
      } else {
        if(reloadCaptcha != null){
          reloadCaptcha!();
        }
        _message = _res['message'] ?? 'Có lỗi xảy ra.'.lang();
        onFail(_message);
        return _message;
      }
    }
    _message = 'Có lỗi xảy ra. Xin vui lòng thử lại!'.lang();
    onFail(_message);
    return _message;
  }
  @override
  void onClose() {
    super.onClose();
  }
}
