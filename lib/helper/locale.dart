import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper/system.dart';
import 'package:vhv_basic/libs/AppLib.dart';
import 'package:vhv_basic/libs/SettingLib.dart';

Locale getCurrentLocale(){
  if(currentLocale != null){
    currentLanguage = currentLocale!.languageCode;
    return currentLocale!;
  }
  else
  {
    currentLocale = Locale('vi', 'VN');
  }
  final String? _currentLanguage = Setting('Config').get('currentLanguage');
  final String? _currentCountry = Setting('Config').get('currentCountry');
  if(!empty(_currentLanguage)){
    currentLocale = Locale(_currentLanguage!, _currentCountry);
    return currentLocale!;
  }
  return const Locale('vi', 'VN');
}
changeLanguage(Locale locale,[bool save = true]) async {
  factories['setClientLanguage'] = locale.languageCode;
  Get.updateLocale(locale);
  if (!Setting('Config').containsKey('hasChangeLanguage')) {
    await Setting('Config').put('hasChangeLanguage', true);
  }
  if(save) {
    currentLocale = locale;
    currentLanguage = locale.languageCode;
    await Setting('Config').put('currentLanguage', currentLanguage);
    await Setting('Config').put('currentCountry', locale.countryCode);
  }
  if (!empty(domains) && domains.length > 1 &&
      domains.containsKey(currentLanguage)) {
    final Map _params = domains[currentLanguage]!.toJson();
    if (!empty(_params)) {
      app.addAll(domains[currentLanguage]!.toJson());
    }
  }
  Get.find<AppLib>().getAppInfo();
}