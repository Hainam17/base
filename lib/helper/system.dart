import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/DioLib.dart';
import 'package:vhv_basic/libs/GetBaseListController.dart';
import 'package:vhv_basic/libs/SettingLib.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/pages/AppNotFound/Page.dart';

const maxPrecision = 12;

enum RoundingType {
  round,
  floor,
  ceil,
}

List<String> _rounding(String? intStr, String? decimalStr, int? decimalLength, RoundingType? type) {
  intStr = intStr ?? '';
  if ((decimalStr == null) || (decimalStr == '0')) {
    decimalStr = '';
  }
  if (decimalStr.length <= decimalLength!) {
    return [intStr, decimalStr];
  }
  decimalLength = max(min(decimalLength, maxPrecision - intStr.length), 0);
  final value = double.parse('$intStr.${decimalStr}e$decimalLength');
  List<String> rstStrs;
  if (type == RoundingType.ceil) {
    rstStrs = (value.ceil() / pow(10, decimalLength)).toString().split('.');
  } else if (type == RoundingType.floor) {
    rstStrs = (value.floor() / pow(10, decimalLength)).toString().split('.');
  } else {
    rstStrs = (value.round() / pow(10, decimalLength)).toString().split('.');
  }
  if (rstStrs.length == 2) {
    if (rstStrs[1] == '0') {
      rstStrs[1] = '';
    }
    return rstStrs;
  }
  return [rstStrs[0], ''];
}

Future<PackageInfo> getPackageInfo()async{
  if(!Platform.isWindows) {
    return await PackageInfo.fromPlatform();
  }
  return PackageInfo(packageName: '', appName: '', version: '', buildNumber: '');
}

String shortNumber(num? value, {
  int length = 6,
  int? decimal,
  String placeholder = '',
  String? separator,
  String? decimalPoint,
  RoundingType roundingType = RoundingType.round,
  List<String> units = const ['N', 'M', 'G', 'T', 'P'],
  bool numDetail = false,
}){
  separator = separator??((currentLanguage == 'vi') ? '.' : ',');
  decimalPoint = decimalPoint??((currentLanguage == 'vi') ? ',' : '.');
  decimal ??= length;
  placeholder = placeholder.substring(0, min(length, placeholder.length));
  if (value == null || !value.isFinite) {
    return placeholder;
  }
  final valueStr = num.parse(value.toStringAsPrecision(maxPrecision)).toString();
  var roundingRst = _rounding(
    RegExp(r'\d+').stringMatch(valueStr) ?? '',
    RegExp(r'(?<=\.)\d+$').stringMatch(valueStr) ?? '',
    decimal,
    roundingType,
  );
  var integer = roundingRst[0];
  final localeInt = integer.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );
  final sections = localeInt.split(',');
  String subnum = '';
  if((value.toString().length > length) && length >= 3){
    if(numDetail && sections[1] != '000') {
      subnum = sections[1].toString().substring(0,1);
    }
    return '${sections.first}${!empty(subnum) ? '.$subnum' : ''}${units.elementAt(sections.length - 2)}';
  }
  return number(value);
}
goToHome(){
  String _route =
      factories['initialPage'] ?? '/Home';
  if (appNavigator.currentRoute !=
      _route) {
    appNavigator
        .pushNamedAndRemoveAllUntil(
        _route);
  }
}

hasAction(String action, [String? groupId]) {
  if (!empty(account['isOwner'])) return true;
  if (empty(groupId)) groupId = account['cmsGroupId'];
  if (!empty(groupId) &&
      !empty(account['accountActions']) &&
      account['accountActions'] is Map) {
    if(action.indexOf(',') != -1){
      bool _hasAction = false;
      action.split(',').forEach((element) {
        if(inArray(element, account['accountActions'][groupId])){
          _hasAction = true;
        }
      });
      return _hasAction;
    }
    if (account['accountActions'].containsKey(groupId)) {
      return inArray(action, account['accountActions'][groupId]);
    }
  }
  return false;
}

changeTail(String object, [String? replace]) {
  return '${object.substring(0, (object.lastIndexOf('.')) + 1)}${replace ?? ''}';
}

bool inArray(dynamic value, var array) {
  if (!empty(value) && !empty(array)) {
    if (array is List || array is Map) {
      if (array is Map) {
        return array.containsValue(value);
      }
      if (array is List) {
        return array.contains(value);
      }
    }
    return false;
  }
  return false;
}

bool isset([dynamic data]) {
  if (data != null) return true;
  return false;
}

checkEmpty(dynamic data) {
  return !empty(data) ? data : null;
}

bool empty([dynamic data, bool acceptZero = false]) {

  if (data != null) {
    if ((data is Map || data is List) && data.length == 0) {
      return true;
    }
    if ((data is Map || data is Iterable) && data.isEmpty) {
      return true;
    }
    if (data is bool) {
      return !data;
    }
    if ((data is String || data is num) && (data == '0' || data == 0)) {
      if (acceptZero) {
        return false;
      }else{
        return true;
      }
    }
    if (data.toString().isNotEmpty) {
      return false;
    }
  }
  return true;
}

int time() {
  final int _now =
  (((new DateTime.now()).millisecondsSinceEpoch) / 1000).ceil();
  if(Setting().containsKey('differenceTime')){
    return _now + (Setting().get('differenceTime') as int);
  }
  return _now;
}

DateTime dateTimeNow([int? second]){
  return DateTime.fromMillisecondsSinceEpoch(((second != null)?second:time()) * 1000);
}

hasComponent(String component) {
  final _components = Setting('Config').get('site');
  if (!empty(_components) &&
      !empty(_components['components']) &&
      _components['components'] is Map) {
    if (_components['components'].containsKey(component)) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}

getTitle(String service, var id, {Map<String, dynamic>? params}) async {
  final _res = await call(service, params: <String, dynamic>{
    'setClientLanguage': currentLanguage
  }..addAll(params??{}),
      cacheTime: Duration(days: 1), forceRefresh: false);
  if (!empty(_res)) {
    final List _data = (_res is List)
        ? _res
        : (!empty(_res['items'])
        ? (_res['items'] is Map)
        ? (_res['items'].values.toList())
        : _res['items']
        : []);
    for(Map element in _data){
      if('${element['id'] ?? element['code']}' == id){
        return (currentLanguage == 'en' || (!empty(params) && !empty(params!['englishTitle'])))
            ? (!empty(element['englishTitle'])
            ? element['englishTitle']
            : (element['title']??''))
            : (element['label'] ?? element['title']);
      }

    }
  }else if(_res == null){
    clearCache(service, params: params);
  }

  return '';
}

showMessage(
    message, {
      String? type,
      bool slow = true,
      int timeShow = 2,
    }) {
  final _type = (type != null) ? type.toUpperCase() : '';
  Color _color;
  switch (_type.toUpperCase()) {
    case 'SUCCESS':
      _color = Colors.green;
      break;
    case 'FAIL':
      _color = Colors.red;
      break;
    case 'ERROR':
      _color = Colors.red;
      break;
    case 'WARNING':
      _color = Colors.deepOrange;
      break;
    default:
      _color = Colors.blue;
  }
  BotToast.showNotification(
    backgroundColor: _color,
    duration: Duration(seconds: timeShow),
    title: (_){
      return Text(
        message.toString().lang(),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
        ),
      );
    }
  );
}


cancelAllMessage() {
  BotToast.cleanAll();
}

exitApp(){
  if(!isWeb) {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}

// ignore: non_constant_identifier_names
print_r(var data) {
  if (data is Map) {
    data.forEach((key, value) {
      print('(${value.runtimeType})$key: $value');
    });
  }else if (data is List) {
    data.forEach((value) {
      print('(${value.runtimeType}): $value');
    });
  } else {
    print(data);
  }
}
Widget printPre(var data, [int level = 0]){
  if (data is Map) {
    List<Widget> _children = [];
    _children.add(Text('Map('));
    data.forEach((key, value) {
      _children.add(Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$key =>'),
            Expanded(child: printPre(value, level + 1))
          ],
        ),
      ));
    });
    _children.add(Text(')'));
    if(_children.length == 2)_children = [Text('Map()')];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children,
    );
  }else if (data is List) {
    List<Widget> _children = [];
    _children.add(const Text('List['));
    data.forEach((value) {
      _children.add(Padding(
        padding: const EdgeInsets.only(left: 10),
        child: printPre(value, level + 1),
      ));
    });
    _children.add(const Text(']'));
    if(_children.length == 2)_children = [const Text('List[]')];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _children,
    );
  } else {
    return Text('$data');
  }
}



String date([dynamic time, String? format]) {
  String _format = format ?? 'dd/MM/yyyy';
  if (!empty(time)) {
    if ((time is String || time is num)) {
      if(time is int){
        return DateFormat(_format).format(DateTime.fromMillisecondsSinceEpoch(time * 1000));
      }
      final _reg = new RegExp(r'(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})');
      if(time is String && _reg.hasMatch(time)){
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime dateTime = dateFormat.parse(time.toString().replaceFirst('T', ' '));

        return DateFormat(_format).format(dateTime);
      }
      return DateFormat(_format).format(time.toString().toDateTime());
    }else if(time is DateTime){
      return DateFormat(_format).format(time);
    }
  }else{
    return '';
  }
  return '';
}


String number(dynamic value) {
  if(value is num || (value is String && RegExp(r'^\d+$').hasMatch(value))) {
    final RegExp _reg = RegExp(r'(\d)(?=(\d{3})+$)');
    final newString = value.toString().replaceAllMapped(_reg, (match) {
      return '${match.group(1)}${(currentLanguage == 'vi') ? '.' : ','}';
    });
    return newString;
  }
  return value;
}
String currency(dynamic value, {String? currencyUnit, int? decimalDigits, bool useShort = false}){
  if(value != null) {
    if(value is String && !RegExp(r'^\d+$').hasMatch(value))return value;
    final String _unit = currencyUnit??(factories[useShort?'shortCurrency':'currency']??'đ');
    String _locale = currentLocale.toString();
    if(_unit == '\$' || _unit.toLowerCase() == 's\/'){
      _locale = 'en_US';
    }
    int dec = decimalDigits??0;
    if(value is double){
      final _r = value.toString().substring(value.toString().lastIndexOf('.') + 1);
      if(!empty(_r)){
        dec = _r.length;
      }else{

      }
    }
    var f = new NumberFormat.currency(
        locale: _locale, name: currencyUnit??(factories[useShort?'shortCurrency':'currency']??'đ'), decimalDigits: dec);
    String _val = value.toString();
    var _log =
    f.format((double.tryParse(_val))??0.0);
    return _log.toString();
  }
  return '';
}
double parseDouble(dynamic data, [double defaultValue = 0]){
  if(data is int) return (data * 1.0);
  if(data is double) return data;
  if(data is String && data != '')return data.parseDouble();
  return defaultValue;
}
int parseInt(dynamic data){
  if(data is int) return data;
  if(data is double) return data.ceil();
  if(data is String && RegExp(r'^\d+$').hasMatch(data))return data.parseInt();
  return 0;
}
num round(var data, [int places = 1]) {
  if((data is num && data != double.infinity) || (data is String && RegExp(r'^\d+$').hasMatch(data))){
    double mod = parseDouble(pow(10.0, places));
    final double _res = (('$data'.parseDouble() * mod).round().toDouble() / mod);
    if(_res == _res.ceil()){
      return _res.ceil();
    }
    return _res;
  }
  return parseDouble(data);
}
arrayIntersect(final List? list1, final List? list2){
  if(list1 == null || list2 == null){
    return [];
  }
  List _temp = [];
  list1.forEach((element) {
    if(list2.contains(element) && !_temp.contains(element)){
      _temp.add(element);
    }
  });
  return _temp;
}
convertUtf8ToLatin(String val){
  List<String> _source = [
    "áàạảãâấầậẩẫăắằặẳẵàầằ",
    "ÁÀẠẢÃÂẤẦẬẨẪĂẮẰẶẲẴẦÀẰ",
    "éèẹẻẽêếềệểễeề",
    "ÉÈẸẺẼÊẾỀỆỂỄỀÈ",
    "óòọỏõôốồộổỗơớờợởỡ",
    "ÓÒỌỎÕÔỐỒỘỔỖƠỚỜỢỞỠ",
    "úùụủũưứừựửữ",
    "ÚÙỤỦŨƯỨỪỰỬỮ",
    "íìịỉĩ",
    "ÍÌỊỈĨ",
    "đ",
    "Đ",
    "ýỳỵỷỹ",
    "ÝỲỴỶỸ"
  ];
  List<String> _replace = "aAeEoOuUiIdDyY".split('');
  return (val.replaceAll('ề', 'ề')).split('').map((e){
    int? _index;
    _source.forEach((element) {
      if(element.indexOf(e) != -1)_index = _source.indexOf(element);
    });
    if(_index != null)return _replace[_index!];
    return e;
  }).toList().join('');
}

appFound(Map data){
  if(factories['appStatus'] != data['status'] && empty(factories['logOuting'])) {
    factories.addAll({
      'appStatus': data['status']
    });
    final _data = {}..addAll(data);
    if(!empty(factories['appFoundMessage'])){
      _data.addAll({
        'message': factories['appFoundMessage']
      });
    }
    appNavigator.pushAndRemoveAllUntil(() =>
        AppNotFoundPage(params: _data));
  }
}

Color? darken(Color? color, [double amount = .1]) {
  if(color == null){
    return null;
  }
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color? lighten(Color? color, [double amount = .1]) {
  if(color == null){
    return null;
  }
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

sendDeviceId([String? token])async{
  if(token != null && (!factories.containsKey('deviceId') || token != factories['deviceId'])) {
    call('Member.Device.log', params: {
      'androidRegistrationId': token,
    });
  }
  factories.remove('deviceId');
}
void showLoading(){
  BotToast.showLoading();
}
void disableLoading(){
  BotToast.closeAllLoading();
}


showFullFilter<T extends GetBaseListController>(
    {@required Widget Function(T controller) ?childBuilder,
      String? tagController,
      Function? onSearch,
      Function? onCancel,
      String? title,
      Widget? bottom,
      EdgeInsets? padding,
      ButtonStyle? styleButton,
      Color? backgroundColor}) async {
  final controller = Get.find<T>(tag: tagController);
  return await appNavigator.showFullDialog(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              appNavigator.pop();
            },
          ),
          title: Text('${title ?? 'Bộ lọc'}'.lang()),
          centerTitle: true,
          actions: <Widget>[
            if(onCancel != null)TextButton(
                onPressed: () {
                },
                child: Text(
                  'Đặt lại'.lang(),
                  maxLines: 1,
                )
            )
          ],
          elevation: .5,
        ),
        backgroundColor: (backgroundColor != null)
            ? backgroundColor
            : Theme.of(currentContext).cardColor,
        body: Column(
          children: <Widget>[
            Expanded(
                child: ListView(
                  children: [
                    GetBuilder<T>(
                      tag: tagController,
                      builder: (_controller) {
                        if (childBuilder != null) return childBuilder(controller);
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                )),
            Padding(
                padding: padding ??
                    EdgeInsets.only(
                        left: paddingBase,
                        right: paddingBase,
                        top: 10,
                        bottom:
                        MediaQuery.of(currentContext).viewPadding.bottom +
                            paddingBase),
                child: (bottom != null) ? bottom
                    : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: TextButton(
                          style: styleButton ??
                              TextButton.styleFrom(
                                backgroundColor: const Color(0xff005CB6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                          onPressed: () {
                            if (onSearch != null) onSearch(controller);
                            appNavigator.pop('onSearch');
                          },
                          child: Text(
                            'Áp dụng'.lang(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17
                            ),
                          )),
                    ),
                    InkWell(
                      child: Container(
                        height: 5,
                        width: 135,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xff000000),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      onTap: () {
                        appNavigator.pop();
                      },
                    )
                  ],
                )
            ),
          ],
        ),
      )
  );
}