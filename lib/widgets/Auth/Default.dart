import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';
import 'package:vhv_basic/form.dart';
import 'package:vhv_basic/import.dart';
import 'Controller.dart';
import 'ForgotPassword/Default.dart';
import 'LoginForm/flutter_login.dart';
import 'LoginForm/src/providers/auth.dart';

class AuthDefault extends StatefulWidget {
  final bool isLogin;

  const AuthDefault({Key? key, this.isLogin: true}) : super(key: key);

  @override
  State<AuthDefault> createState() => _AuthDefaultState();
}

class _AuthDefaultState extends State<AuthDefault> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  @override
  void dispose() {
    Future.delayed(Duration(seconds: 3),(){
      if(Get.isRegistered<AuthController>()){
        Get.delete<AuthController>();
      }
    });
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final AuthPageOption _authPageOption = (authPageOption != null)
        ? authPageOption!()
        : AuthPageOption();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _authPageOption.systemUiOverlayStyle ?? SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Builder(
          builder: (_) {
            Color _backgroundColor = Colors.black87;
            if (!Get.context!.isDarkMode) {
              _backgroundColor =
                  _authPageOption.primaryColor ?? Colors.blue;
            }
            return GetBuilder<AuthController>(
              init: AuthController(),
              assignId: true,
              autoRemove: true,
              builder: (_model) {
                return FlutterLogin(
                  title: _authPageOption.title ?? app['title'],
                  titleTag: 'title-app',
                  logo: _authPageOption.logo,
                  logoTag: 'logo-app',
                  hideRegister: !factories['hasRegister'],
                  headerRegister: Text(
                    'Đăng ký thành viên'.lang(),
                    style: TextStyle(
                        fontSize: Theme
                            .of(context)
                            .textTheme
                            .headline5!
                            .fontSize,
                        color: Colors.white),
                  ),
                  authMode:
                  (widget.isLogin || !factories['hasRegister'])
                      ? AuthMode.Login
                      : AuthMode.Signup,
                  forgotPassword: (_authPageOption.hideForgotPassword!) ? null
                      : ((_authPageOption.forgotPassword != null)
                      ? _authPageOption.forgotPassword!()
                      : AuthForgotPasswordDefault(
                    primaryColor: _backgroundColor,
                  )),
                  messages: LoginMessages(
                    usernameHint: (_authPageOption.usernameTitle ?? 'Tài khoản')
                        .toString()
                        .lang(),
                    fullNameHint: 'Tên người dùng'.lang(),
                    passwordHint: 'Mật khẩu'.lang(),
                    confirmPasswordHint: 'Nhập lại mật khẩu'.lang(),
                    loginButton: 'Đăng nhập'.lang(),
                    signupButton: 'Đăng ký'.lang(),
                    forgotPasswordButton: 'Quên mật khẩu?'.lang(),
                    goBackButton: 'Trở lại'.lang(),
                    confirmPasswordError: 'Mật khẩu nhập lại không khớp!'
                        .lang(),
                  ),
                  theme: LoginTheme(
                    primaryColor: _authPageOption.primaryColor ?? Colors.blue,
                    accentColor: Colors.blue,
                    errorColor: Colors.deepOrange,
                    pageColorLight: _backgroundColor.withOpacity(0.8),
                    pageColorDark: _backgroundColor,
                    textFieldStyle: TextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyText1!
                          .color,
                    ),
                    buttonStyle: TextStyle(fontFamily: 'roboto'),
                  ),
                  emailValidator: (value) {
                    return _model.validUsername(value!, widget.isLogin);
                  },
                  fullNameValidator: (value) {
                    return _model.validFullName(value!);
                  },
                  passwordValidator: (value) {
                    return _model.validPassword(value!);
                  },
                  onLogin: (loginData) async {
                    final _result = await _model.submit(loginData);
                    return _result;
                  },
                  onSignup: (loginData) {
                    return _model.register(loginData);
                  },
                  signUpExtra: Obx(() =>
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: FormCaptcha(
                          errorText: _model.captchaMessage.value,
                          prefixIcon: Icon(
                            Icons.vpn_key,
                            size: 22,
                          ),
                          onChanged: (data) {
                            _model.captcha = data;
                          },
                          buildReloadCaptcha: (reload) {
                            _model.reloadCaptcha = reload;
                          },
                        ),
                      )),
                  onSubmitAnimationCompleted: (val) async {
                    if (val || _model.hasLogin) {
                      goToHome();
                    } else {
                      if (Get.currentRoute != '/Account/Login') {
                        appNavigator.pushNamedAndRemoveAllUntil(
                            '/Account/Login');
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ));
  }
}