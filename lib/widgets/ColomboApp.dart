import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

final botToastBuilder = BotToastInit();
class ColomboApp extends StatefulWidget {
  final RouteFactory? onGenerateRoute;
  final ThemeMode? themeMode;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final bool? hasLocale;
  final String? initialRoute;
  final Widget? home;
  final Translations? translations;
  final List<AsyncCallbackFunc>? callInMyApps;
  final Iterable<Locale>? supportedLocales;
  final Locale? fallbackLocale;
  final Locale? startLocale;
  const ColomboApp(
      {Key? key,
      this.onGenerateRoute,
      this.themeMode,
      this.theme,
      this.darkTheme,
      this.hasLocale: false,
      this.initialRoute,
      this.supportedLocales,
      this.home, this.translations, this.callInMyApps, this.fallbackLocale, this.startLocale})
      : super(key: key);

  @override
  _ColomboAppState createState() => _ColomboAppState();
}

class _ColomboAppState extends State<ColomboApp> {
  @override
  void initState() {
    if(!empty(widget.callInMyApps)){
      widget.callInMyApps!.forEach((element) {
        element();
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppLib>(
      init: AppLib(),
      builder: (_controller){
        if(widget.startLocale != null && currentLocale == null)currentLocale = widget.startLocale!;
        return GetMaterialApp(
          locale: (widget.translations != null) ? getCurrentLocale() : null,
          theme: widget.theme ??
              ThemeData(
                brightness: Brightness.light,
              ),
          darkTheme: widget.darkTheme ?? ThemeData(brightness: Brightness.dark),
          themeMode: widget.themeMode??currentTheme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            SfGlobalLocalizations.delegate
          ],
          supportedLocales: widget.supportedLocales??[
            const Locale('vi', 'VN')
          ],
          title: app['title'],
          onGenerateRoute: widget.onGenerateRoute,
          navigatorObservers: (factories['navigatorObservers'] != null)
              ?(<NavigatorObserver>[BotToastNavigatorObserver()]..addAll([factories['navigatorObservers']])):<NavigatorObserver>[BotToastNavigatorObserver()],
          //fallbackLocale:widget.fallbackLocale??Locale('en', 'US'),
          translations: widget.translations??BasicTranslations(),
          initialRoute: widget.initialRoute ?? '/',
          home: (widget.onGenerateRoute == null) ? (widget.home ?? const _NoRoute()) : null,
          // builder: EasyLoading.init(),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.1);
            child = MediaQuery(
              child: child!,
              data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
            );
            child = botToastBuilder(context,child);
            return child;
          },
        );
      },
    );
  }
}

class _NoRoute extends StatelessWidget {
  const _NoRoute();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please setup route'),
            BackButton(
              onPressed: (){
                appNavigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
