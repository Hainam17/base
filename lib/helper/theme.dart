import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/libs/SettingLib.dart';

String themeToString() {
  switch (currentTheme) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    default:
      return 'system';
  }
}
ThemeMode themeConvert([String? theme]) {
  switch (theme) {
    case 'light':
      currentTheme = ThemeMode.light;
      break;
    case 'dark':
      currentTheme = ThemeMode.dark;
      break;
    default:
      currentTheme = ThemeMode.system;
  }
  return currentTheme;
}
changeTheme(String theme) async {
  switch (theme) {
    case 'light':
      currentTheme = ThemeMode.light;
      Setting('Config').put('theme', 'light');
      break;
    case 'dark':
      currentTheme = ThemeMode.dark;
      Setting('Config').put('theme', 'dark');
      break;
    default:
      currentTheme = ThemeMode.system;
      Setting('Config').put('theme', 'system');
  }
  Get.changeThemeMode(currentTheme);
}