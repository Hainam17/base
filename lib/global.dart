import 'dart:async';
import 'dart:io' show Directory;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/libs/NavigatorLib.dart';
import 'package:vhv_basic/libs/SettingLib.dart';
import 'package:vhv_basic/widgets/Footer/Default.dart';
import 'package:vhv_basic/widgets/Header/Default.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'libs/AccountLib.dart';
export 'dart:convert';
typedef AsyncCallbackFunc = Future<void> Function();
typedef ValueChangedAsync = Future Function(Map value);

List<CameraDescription> cameras = [];

Map<String, dynamic> app = {'id': 0, 'title': 'App'};
Map<String, Site> domains = {'vi': Site(domain: '', id: 0, title: '')};
late AccountLib account = AccountLib();
Map<String, dynamic> factories = {
  'header': headerDefault,
  'footer': footerDefault,
  'login': {},
  'initialPage':'/Start',
  'loginSuccess': <Function(Map)>[],
  'filterBarType': FilterBarType.Type1,
  'loginFeature': LoginOption.no
};
Function? setupData;
late NavigatorLib appNavigator;
BuildContext get currentContext => Get.context!;
String csrfToken = '';
ThemeMode currentTheme = ThemeMode.system;
String currentLanguage = 'vi';
Directory? appDocumentDirectory;
Locale? currentLocale;
int get differenceTime => _differenceTime();
int _differenceTime(){
  return Setting().get('differenceTime')??0;
}
VoidCallback? appRefresh;
AsyncCallbackFunc? afterLogout;
late AsyncCallbackFunc logout;
late Function(Map, [bool]) login;
late double paddingBase = 12.0;
late List<DeviceOrientation> appOrientations;
ConnectivityStatus? connectionStatus;
AuthPageOption Function()? authPageOption;

class AuthPageOption{
  final String? registerPage;
  final Color? btnLoginColor;
  final TextStyle? btnLoginStyle;
  final TextStyle? versionStyle;
  final String? title;
  final String? usernameTitle;
  final TextInputType? usernameTextInputType;
  final Color? titleColor;
  final double? titleFontSize;
  final double? titleShadow;
  final int? fontWeightDelta;
  final String? logo;
  final double? logoWidth;
  final double? logoSpace;
  final String? background;
  final String? secondBackground;
  final Color? backgroundColorLight;
  final Color? primaryColor;
  final Widget Function()? backgroundBuilder;
  final Widget Function()? coatingBuilder;
  final Widget Function()? headerOutside;
  final Widget Function()? headerInside;
  final Widget Function()? forgotPassword;
  final Widget Function()? extraLoginType;
  final Widget Function()? extraSignUp;
  final Widget Function()? extraRuler;
  final bool? showVersion;
  final bool? hideForgotPassword;
  final double? widthLoginButton;
  final Widget Function(bool isRecover)? extraBottom;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  const AuthPageOption({this.systemUiOverlayStyle, this.widthLoginButton, this.coatingBuilder,
    this.extraRuler, this.extraSignUp, this.extraLoginType, this.headerInside,
    this.registerPage, this.usernameTitle = 'Tài khoản', this.forgotPassword,
    this.hideForgotPassword = false, this.backgroundColorLight, this.primaryColor,
    this.logo, this.title, this.btnLoginColor, this.titleColor,
      this.titleFontSize, this.titleShadow,this.fontWeightDelta, this.logoWidth,
      this.logoSpace, this.background, this.secondBackground,
      this.backgroundBuilder, this.headerOutside, this.showVersion = false, this.extraBottom, this.btnLoginStyle, this.versionStyle, this.usernameTextInputType});
//  AuthPageOption copyWith({
//  final Color btnLoginColor,
//    final Color titleColor,
//    final double titleFontSize,
//    final double titleShadow,
//    final double logoWidth,
//    final double logoSpace,
//    final String background,
//    final String secondBackground,
//    final Widget Function() backgroundBuilder,
//    final Widget Function() headerOutside,
//    final bool showVersion,
//    final Widget Function() extraBottom,
//  }){
//
//  }

}

class Site {
  final String domain;
  final int? id;
  final String title;
  Site({required this.domain, this.id, required this.title});
  Map<String, dynamic> toJson() {
    Map<String, dynamic> _data = new Map<String, dynamic>();
    _data['id'] = this.id;
    _data['domain'] = this.domain;
    _data['title'] = this.title;
    return _data;
  }
}
enum LoginOption {no,yes,required}
enum ConnectivityStatus {wifi,cellular,bluetooth,ethernet,offline}
enum FilterBarType{Type1,Type2}