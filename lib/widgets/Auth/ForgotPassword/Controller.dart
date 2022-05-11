import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class AuthForgotPasswordController extends GetBaseController {
  int _index = 0;
  final FocusNode _captchaFocusNode = FocusNode();
  AuthForgotPasswordController():super(
    rules: {
      'password': {
        'required': 'Bạn chưa nhập mật khẩu mới.',
        'password': true,
        'invalidPassword': ['123456aA@','12345678aA@','Demo@123'],
      },
      'confirmPassword': {
        'required': 'Bạn chưa nhập lại mật khẩu mới.',
        'equalTo': [
          'password',
          'Nhập lại mật khẩu không khớp với mật khẩu đã nhập'
        ]
      },
    },
    useFields: false,
    submitService: 'Member.User.forgotPassword',
    initFields: <String, dynamic>{
      'protocol': ((hasComponent('Project.STDV'))?'phone':'email'),
      'username': '',
    }
  );
  
  Map<String, String> _helper = {
    'otp': 'Mã OTP đã được gửi về email của bạn'.lang()
  };

  FocusNode get captchaFocusNode => _captchaFocusNode;
  int get index => _index;
  Map<String, String> get helper => _helper;
  bool _reverse = true;
  bool _isValidusername = false;
  bool get reverse => _reverse;
  bool get isValidusername => _isValidusername;

  VoidCallback? reloadCaptcha;

  set captcha(String captcha) {
    fields.addAll({
      'captcha_code': captcha
    });
    if (errorMessages['captcha'] != null) {
      errorMessages.remove('captcha');
      update();
    }
  }

  next() async {
    errorMessages = {};
    if (_index == 0) {
      bool _check = true;
      if (fields['username'] == null || fields['username'].isEmpty) {
        errorMessages.putIfAbsent(
            'username', () => 'Tài khoản không được để trống.'.lang());
        _check = false;
      }
      if (empty(fields['captcha_code'])) {
        errorMessages.putIfAbsent(
            'captcha', () => 'Mã xác thực không được để trống.'.lang());
        _check = false;
      }
      if (_check) {
        await _sendOTP();
      }
    } else if (_index == 1) {
      if (fields['otp'] == null || fields['otp'].isEmpty) {
        errorMessages.putIfAbsent('otp', () => 'Bạn chưa nhập mã OTP.'.lang());
      } else {
        await _checkOTP();
      }
    } else if (_index == 2) {
      submit();
    }
    update();
  }

  _sendOTP() async {
    final _res = await call('Member.User.sendOTP',
        params: fields..addAll(
          !empty(fields['protocol']) &&!empty(fields['protocol']=='phone')?{'sendSMS':'1'}:{},
        )
    );
    if (_res == 'BotDetect') {
      if(!empty(fields['captcha_code'])) {
        errorMessages['captcha'] = 'Mã xác thực không chính xác.'.lang();
        if(reloadCaptcha != null)reloadCaptcha!();
      }else{
        errorMessages['captcha'] = 'Bạn chưa nhập mã xác thực.'.lang();
      }
      update();
    } else if (_res != null) {
      if (_res['status'] != null) {
        if (_res['status'] == 'SUCCESS') {
          if(!empty(_res['message'])){
            _helper['otp'] = _res['message'];
          }
          _next();
        } else if (_res['status'] == 'BotDetect') {
          errorMessages['captcha'] = 'Mã xác thực không đúng.'.lang();
          if(reloadCaptcha != null)reloadCaptcha!();
          update();
        } else if (_res['status'] == 'USER_NOT_EXISTS') {
          errorMessages['username'] = 'Tài khoản không tồn tại.'.lang();
          if(reloadCaptcha != null)reloadCaptcha!();
          update();
        }else if(_res['status'] == 'FAIL' && _res['insertStatus'] == 'EXISTS'){
          if(!empty(_res['message'])){
            _helper['otp'] = _res['message'];
          }
          _next();
        }else {
          showMessage(_res['message'] ?? 'Có lỗi xảy ra!', type: 'FAIL');
          if(reloadCaptcha != null)reloadCaptcha!();
        }
      }
    } else {
      showMessage('Có lỗi xảy ra. Xin vui lòng thử lại sau!'.lang(),
          type: 'FAIL');
      if(reloadCaptcha != null)reloadCaptcha!();
    }
  }

  _checkOTP() async {
    final _res = await call('Member.User.forgotPassword', params: fields);
    if (_res != null) {
      if (_res['status'] != null && _res['status'] == 'SUCCESS') {
        _next();
      } else {
        showMessage(
            _res['message'] ?? 'Có lỗi xảy ra. Vui lòng thử lại sau!'.lang(),
            type: 'FAIL');
      }
    }
  }

  _next() async {
    _reverse = false;
    update();
    await Future.delayed(const Duration(milliseconds: 100));
    _index++;
    update();
  }

  backStep() async {
    if (_index > 0) {
      _reverse = true;
      update();
      await Future.delayed(const Duration(milliseconds: 100));
      _index--;
      update();
      if (_index == 1) fields.remove('captcha_code');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
