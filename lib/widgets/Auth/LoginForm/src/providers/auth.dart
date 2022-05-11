import 'package:flutter/material.dart';

import '../models/login_data.dart';

enum AuthMode { Signup, Login }
/// The result is an error message, callback successes if message is null
typedef AuthCallback = Future<dynamic> Function(LoginData);

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String> Function(String);

class Auth with ChangeNotifier {
  Auth({
    this.authMode:AuthMode.Login,
    this.onLogin,
    this.onSignup,
    String email = '',
    String fullName = '',
    String password = '',
    String confirmPassword = '',
  })  : this._email = email,
        this._fullName = fullName,
        this._password = password,
        this._confirmPassword = confirmPassword;

  final AuthMode authMode;
  final AuthCallback? onLogin;
  final AuthCallback? onSignup;

  AuthMode? _mode;

  AuthMode get mode => _mode??authMode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  reload(){
    notifyListeners();
  }

  bool get isLogin => (_mode??authMode) == AuthMode.Login;
  bool get isSignup => (_mode??authMode) == AuthMode.Signup;
  bool isRecover = false;

  AuthMode opposite() {
    return _mode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.Login) {
      mode = AuthMode.Signup;
    } else if (mode == AuthMode.Signup) {
      mode = AuthMode.Login;
    }
    return mode;
  }

  String _email = '';
  String get email => _email;
  set email(String email) {
    _email = email;
    notifyListeners();
  }
  String _fullName = '';
  String get fullName => _fullName;
  set fullName(String fullName) {
    _fullName = fullName;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }
}
