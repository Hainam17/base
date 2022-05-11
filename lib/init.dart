library init;
import 'dart:io';
// import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:vhv_basic/widgets/CameraViewer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'helper/init.dart';
import 'widgets/ColomboApp.dart';
import 'import.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

init(
    {Site? site,
    Map<String, Site>? sites,
    Widget? child,
    Iterable<Locale>? supportedLocales,
    Locale? startLocale,
    LoginOption login: LoginOption.no,
    bool register: true,
    List<String>? boxes,
    ThemeMode? themeMode,
    ThemeData? theme,
    ThemeData? darkTheme,
    RouteFactory? onGenerateRoute,
    String? initialRoute,
    Widget? home,
    List<AsyncCallbackFunc>? asyncCallbacks,
    List<AsyncCallbackFunc>? callInMyApps,
    List<VoidCallback>? callbacks,
    List<DeviceOrientation>? orientations,
    Translations? translations,
    final Locale? fallbackLocale,
    bool notShowUpdate = true,
    final Widget Function(Widget child)? builder
  }) async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  // if(Platform.isWindows || Platform.isLinux){
  //   DartVLC.initialize();
  // }
  domains = sites ?? domains;
  factories['loginFeature'] = login;
  factories['hasRegister'] = register;

  if(!kIsWeb){
    appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
    if(Platform.isAndroid || Platform.isIOS){
      try {
        cameras = await availableCameras();
      } on CameraException catch (e) {
        logError(e.code, e.description);
      }
    }
  }
  //
  String path;
  if(appDocumentDirectory != null){
    path = appDocumentDirectory!.path;
    Hive.init(path);
  }
  factories['boxStorage'] = boxes;
  Setting.storageLib = new SettingLib();
  await Setting.init('Config');
  final appInfo = await Setting('Config').get('site');

  if(!empty(appInfo) && appInfo is Map){
    if(!empty(appInfo['staticDomain']))app['staticDomain'] = appInfo['staticDomain'];
    if(!empty(appInfo['image']))app['logo'] = appInfo['image'];
  }else{
    app['staticDomain'] = app['domain'];
  }
  final _currentLanguage = await Setting('Config').get('currentLanguage');
  if (translations != null)factories['hasChangeLanguage'] = await Setting('Config').get('hasChangeLanguage');
  currentLanguage = _currentLanguage ?? currentLanguage;
  if (site != null || (sites != null && sites[currentLanguage] != null)) {
    app.addAll((sites != null && sites[currentLanguage] != null)
        ? sites[currentLanguage]!.toJson()
        : site!.toJson());
  }
  if (translations != null) factories['multiLanguage'] = true;
  if (initialRoute != null) factories['initialPage'] = initialRoute;
  if(notShowUpdate){
    factories['notShowUpdate'] = 1;
  }
  factories['rootSiteId'] = app['id'];
 await appLibInit(Setting('Config')['account'], true);
  if (boxes != null) {
    await Setting.init(boxes);
  }
  if (callbacks != null) {
    callbacks.forEach((func) {
      func();
    });
  }
  if (asyncCallbacks != null) {
    await Future.forEach(asyncCallbacks, (AsyncCallbackFunc? element) async{
      await element!();
    });
  }
  appOrientations = orientations ?? [DeviceOrientation.portraitUp];
  await SystemChrome.setPreferredOrientations(
      orientations ?? [DeviceOrientation.portraitUp]);

  runApp(builder != null?builder(ColomboApp(
      translations: translations,
      startLocale: startLocale,
      theme: theme,
      darkTheme: darkTheme,
      supportedLocales: supportedLocales,
      themeMode: themeMode,
      fallbackLocale: fallbackLocale,
      onGenerateRoute: onGenerateRoute,
      initialRoute: initialRoute,
      callInMyApps: callInMyApps,
      home: home)):ColomboApp(
      translations: translations,
      startLocale: startLocale,
      theme: theme,
      darkTheme: darkTheme,
      supportedLocales: supportedLocales,
      themeMode: themeMode,
      fallbackLocale: fallbackLocale,
      onGenerateRoute: onGenerateRoute,
      initialRoute: initialRoute,
      callInMyApps: callInMyApps,
      home: home
    )
  );

}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}