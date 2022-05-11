import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/widgets/BottomSheetMenu.dart';
export 'package:vhv_basic/widgets/BottomSheetMenu.dart';

class NavigatorLib {
  final _navigator = Get;

  String? get currentRoute => _currentRoute;
  String? _currentRoute;
  String _factoriesRouter(String router){
    if(factories['router'] is Map && factories['router'].containsKey(router))return factories['router'][router];
    return router;
  }
  Future<dynamic> pushNamed(String routeName, {dynamic arguments}) async{
    _currentRoute = routeName;
    if(allowRouter(routeName)) {
      print('pushNamed to $_currentRoute');
      return await _navigator.toNamed(
          _factoriesRouter(routeName), arguments: arguments);
    }

  }
  Future<dynamic> pushNamedAndRemoveUntil(String routeName, {dynamic arguments}) async{
    _currentRoute = routeName;
    if(allowRouter(routeName)) {
      print('pushNamedAndRemoveUntil to $_currentRoute');
      return await _navigator.offAndToNamed(
          _factoriesRouter(routeName), arguments: arguments);
    }

  }
  Future<dynamic> pushNamedAndRemoveAllUntil(String routeName, {dynamic arguments}) async{
    _currentRoute = routeName;
    if(allowRouter(routeName)) {
      print('pushNamedAndRemoveAllUntil to $_currentRoute');
      return await _navigator.offAllNamed(
          _factoriesRouter(routeName), arguments: arguments);
    }

  }
  Future<dynamic> push(dynamic route, {Transition? transition, Duration? duration, dynamic arguments}) async{
    _currentRoute = route.toString();
    if(allowRouter(route)) {
      print('push to $_currentRoute');
      return await _navigator.to(route, transition: transition,
          arguments: arguments,
          duration: duration ?? const Duration(milliseconds: 300));
    }

  }
  Future<dynamic> pushAndRemoveUntil(dynamic route, {Transition? transition, Duration? duration}) async{
    _currentRoute = route.toString();
    if(allowRouter(route)) {
      print('pushAndRemoveUntil to $_currentRoute');
      return await _navigator.off(route, transition: transition,
          duration: duration ?? const Duration(milliseconds: 300));
    }

  }
  bool allowRouter(dynamic router){
    if(factories.containsKey('appStatus') && factories['appStatus'] != 'SUCCESS'){
      if(!factories.containsKey('appFoundRouter') && router.toString().contains('AppNotFoundPage')) {
        factories['appFoundRouter'] = 1;
        return true;
      }
      return false;
    }
    return true;
  }

  Future<dynamic> pushAndRemoveAllUntil(dynamic route, {Transition? transition, Duration? duration}) async{
    _currentRoute = route.toString();
    if(allowRouter(route)) {
      print('pushAndRemoveAllUntil to $_currentRoute');
      return await _navigator.offAll(route, transition: transition,
          duration: duration ?? const Duration(milliseconds: 300));
    }

  }


  pop([result]) {
    _currentRoute = Get.previousRoute;
    final _res = _navigator.back(result: result);
    return _res;
  }
  bool isShowFullDialog = false;

  showFullDialog({
    bool barrierDismissible = true,
    required Widget child,
    WillPopCallback? onWillPop,
  })async{
    isShowFullDialog = true;
    final _res = await showFullModal(
      barrierDismissible: barrierDismissible,
      child: child,
      onWillPop: onWillPop
    );
    isShowFullDialog = false;
    return _res;
  }


  showDialog({
    String? title,
    TextStyle? titleStyle,
    Widget? content,
    String? middleText,
    Widget? cancel,
    List<Widget>? actions,
    VoidCallback? onCancel,
    VoidCallback? onCustom,
    VoidCallback? onConfirm,
    Color? confirmTextColor,
    String? textConfirm,
    String? textCancel,
    String? textCustom,
    bool barrierDismissible = true,
    double radius = 10.0,
    WillPopCallback? onWillPop,
  })async{
    return await showModal(
        title: title,
        titleStyle: titleStyle,
        content: content,
        middleText: middleText,
        cancel: cancel,
        actions: actions,
        onCancel: onCancel,
        onCustom: onCustom,
        onConfirm: onConfirm,
        confirmTextColor: confirmTextColor,
        textConfirm: textConfirm,
        textCancel: textCancel,
        textCustom: textCustom,
        barrierDismissible: barrierDismissible,
        radius: radius,
        onWillPop: onWillPop
    );
  }
  dialog(Widget child, {
    bool barrierDismissible = true,
  }){
    return _navigator.dialog(child, barrierDismissible: barrierDismissible);
  }
  bottomSheet({
    final Widget? child,
    final Widget? bottom,
    final dynamic title,
    final Widget? actionRight,
    final Widget? actionLeft,
    final BottomSheetType? type,
    final Color? backgroundColor,
    final EdgeInsets? padding
  })async{
    return await _navigator.bottomSheet(BottomSheetMenu(
      child: child,
      bottom: bottom,
      title: title,
      actionRight: actionRight,
      actionLeft: actionLeft,
      backgroundColor: backgroundColor,
      padding: padding,
      type: type,
    ), isScrollControlled: true, ignoreSafeArea: false);
  }
  bool get isBottomSheetOpen => _navigator.isBottomSheetOpen!;
  bool get isDialogOpen => _navigator.isDialogOpen!;

  BuildContext get context => Get.context!;
}