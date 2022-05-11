import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:vhv_basic/import.dart';

class GetBaseController extends GetxController {
  Map<String, String>? _captcha;
  late Map<String, dynamic> fields = <String, dynamic>{};
  Map<String, dynamic>? selectParams;
  Map<String, dynamic>? extraParams;
  Map? params;
  Map<String, dynamic> errorMessages = <String, dynamic>{};
  late bool useFields = true;
  String? submitService;
  String? service;
  bool mounted = true;
  final Map<String, dynamic>? initFields;
  final List<String>? controllerNames;
  final bool useParams;
  final Duration? cacheTime;

  GetBaseController({this.submitService,
    this.service,
    this.initFields,
    this.selectParams,
    this.extraParams,
    this.rules,
    this.useFields: true,
    this.controllerNames,
    this.useParams = true,
    this.cacheTime,
  });

  bool isSubmitting = false;
  Map<String, Map<String, dynamic>>? rules = {};
  Map<String, String> _msg = {
    'status': 'FAIL',
    'message': 'Có lỗi xảy ra.'.lang()
  };
  Map<String, StreamController<String?>>? inputControllers;
  Map<String, Rx>? inputObs;

  @override
  onInit() {
    if (!empty(initFields)) fields.addAll(initFields!);
    _select();
    createController(controllerNames);
    super.onInit();
  }

  @protected
  select() async {
    await _select();
  }

  _select() async {
    if (!empty(service)) {
      final _res = await call(service!, params: selectParams ?? {},
          forceRefresh: cacheTime != null ? false : true,
          cacheTime: cacheTime,
          hasSite: empty((selectParams ?? {})['usingRootSite'])
      );
      if (_res != null && _res is Map) {
        if (useParams) {
          fields.forEach((key, value) {
            if (_res.containsKey(key)) {
              fields[key] = _res[key];
            }
          });
        }
        params = await checkItem(_res);
      } else {
        params = {};
      }
      update();
    }
  }

  @protected
  checkItem(Map item) async {
    return item;
  }

  createController(List<String>? inputNames) {
    inputNames?.forEach((element) {
      if (element.endsWith('Stream')) {
        if (inputControllers == null) inputControllers = {};
        inputControllers![element] = new StreamController();
      } else if (element.endsWith('Obs')) {
        if (inputObs == null) inputObs = {};
        inputObs![element] = null.obs;
      }
    });
  }

  dynamic operator [](String name) {
    if (name.endsWith('Stream') &&
        inputControllers != null &&
        inputControllers!.containsKey(name.substring(0, name.length - 6))) {
      return inputControllers![name.substring(0, name.length - 6)]!.stream;
    } else if (name.endsWith('Obs') && inputObs != null) {
      if (inputObs!.containsKey(name.substring(0, name.length - 3))) {
        return inputObs![name.substring(0, name.length - 3)]!.value;
      } else {
        return null;
      }
    }
    if (fields.containsKey(name)) {
      return fields[name];
    } else if (useParams && params != null && params!.containsKey(name)) {
      if (!fields.containsKey(name) && params![name] != null) {
        fields.addAll({
          name: params![name]
        });
      }
      return fields[name];
    }
  }

  void operator []=(String name, value) {
    if (name == 'captcha') {
      _captcha = value;
    }
    bool hasReload = true;
    if (inputObs != null && inputObs!.containsKey(name)) {
      inputObs![name]!.value = null;
      hasReload = false;
    }
    if (name.endsWith('Stream') &&
        inputControllers != null &&
        inputControllers!.containsKey(name.substring(0, name.length - 6))) {
      inputControllers![name.substring(0, name.length - 6)]!.sink.add(null);
      hasReload = false;
    }
    if (errorMessages.containsKey(name)) {
      errorMessages.remove(name);
      if (hasReload) {
        update();
      }
    }
    fields[name] = (value is String) ? value.trim() : value;
  }

  reload() {
    update();
  }

  submit() async {
    if (connectionStatus == ConnectivityStatus.offline) {
      showMessage('Bạn vui lòng kiểm tra lại kết nối mạng!', type: 'ERROR');
    } else {
      FocusScope.of(currentContext).requestFocus(new FocusNode());
      errorMessages = {};
      if (!isSubmitting) {
        if (checkValid(fields) == true) {
          _showLoading();
          if(!empty(submitService)){
            await _send();
          }else{
            showMessage('Chưa có service', type: 'warning');
            _disableLoading();
          }
        } else {
          await onErrorValidation();
        }
        return _msg;
      }
    }
  }

  @protected
  onSuccess(response) async {
    Future.delayed(Duration(seconds: 1), () {
      _disableLoading();
    });
    _msg['message'] = (response is Map && response['message'] != null)
        ? response['message']
        : 'Cập nhật thành công'.lang();
  }

  _showLoading() {
    isSubmitting = true;
    showLoading();
  }

  _disableLoading() {
    isSubmitting = false;
    disableLoading();
  }

  @protected
  onFail(response) async {
    _disableLoading();
    if (response == null) {
      _msg['message'] = 'Có lỗi xảy ra.'.lang();
    } else {
      if (response != null && response is String) {
        if (response == 'BotDetect') {
          _msg['message'] =
              'Bạn chưa nhập mã bảo mật hoặc mã bảo mật không đúng.'.lang();
        }
      }
      else {
        if (response != null && response is Map) {
          if (response['message'] != null) {
            _msg['message'] = response['message'];
          }
        }
      }
    }
  }

  @protected
  onErrorValidation() async {
    _disableLoading();
    _msg.addAll({
      'status': 'FAIL',
      'message': 'Bạn vui lòng kiểm tra lại thông tin!'.lang()
    });
  }

  onSend(response) async {
    if (response != null &&
        ((response is Map && response['status'] != null) ||
            response is String)) {
      _msg['status'] = (response is String) ? response : response['status'];
      if (_msg['status'] == 'SUCCESS') {
        await onSuccess(response);
      } else {
        await onFail(response);
      }
    } else {
      await onFail(response);
    }
  }

  _send() async {
    Map<String, dynamic>? submitFields;
    final _fields = <String, dynamic>{};
    fields.forEach((key, value) {
      if((value is List)){
        _fields.addAll(<String, dynamic>{
          key: jsonEncode(value)
        });
      }else{
        _fields.addAll(<String, dynamic>{
          key: value
        });
      }
    });
    if (useFields) {
      submitFields = {'fields': _fields}..addAll(extraParams ?? {});
    } else {
      submitFields = _fields..addAll(extraParams ?? {});
    }
    if (_captcha != null) submitFields.addAll(_captcha!);
    final _res = await call(submitService!, params: submitFields
      ..addAll(<String, dynamic>{
        'setClientLanguage': currentLanguage,
      }));
    await onSend(_res);
  }

  returnMessageError(key, message) {
    errorMessages[key] = message;
    if (inputControllers != null && inputControllers!.containsKey(key)) {
      inputControllers![key]!
          .addError((message is String) ? message.lang() : message);
    } else if (inputObs != null && inputObs!.containsKey(key)) {
      inputObs![key]!.value = (message is String) ? message.lang() : message;
    }
  }

  @protected
  extraRules(Map<String, Map<String, dynamic>> rules) {
    return rules;
  }

  bool checkValid(Map<String, dynamic> fields,
      [Map<String, Map<String, dynamic>>? customRules]) {
    errorMessages = {};
    bool _error = false;
    if (inputControllers != null &&
        inputControllers!.length > 0) inputControllers!.forEach((key, value) {
      value.add('');
    });
    Map<String, Map<String, dynamic>> _extra = extraRules(
        <String, Map<String, dynamic>>{});
    (customRules ?? ((_extra)
      ..addAll(rules ?? <String, Map<String, dynamic>>{}))).forEach((key,
        subRules) {

      var value = (fields.containsKey(key) && fields[key] != null)
          ? fields[key]
          : null;
      if (value == null && useParams && !empty(params) && params is Map &&
          params!.containsKey(key)) {
        fields[key] = params![key];
        value = params![key];
      }
      if(subRules.containsKey('*')){

        subRules.forEach((subKey, message) {
          if(message is Map && subKey == '*'){
            Map _err = {};
            message.forEach((messageK, messageV){
              if(!empty(value, empty(subRules['required'])) && value is Map){
                value.forEach((_k, _v) {
                  if(!_err.containsKey(_k)){
                    _err.addAll({
                      _k: {}
                    });
                  }
                  if(!empty(subRules['required']) && !value[_k].containsKey(messageK)){
                    value[_k].addAll({
                      messageK: null
                    });
                  }
                  if(_v is Map){
                    _v.forEach((_vK, _vV) {
                      (messageV as Map).forEach((messageVK, messageVV) {
                        final m = _processValid(
                          key: messageVK,
                          value: _v[messageK],
                          message: messageVV,
                        );
                        if(!empty(m)){
                          _error = true;
                          if(!_err[_k].containsKey(messageK)) {
                            _err[_k].addAll({
                              messageK: messageVV
                            });
                          }
                        }
                      });
                    });
                  }
                });
              }
            });
            returnMessageError(key, _err);
          }
        });
      }else{
        subRules.forEach((subKey, message) {
          final _m = _processValid(
            key: subKey,
            value: value,
            message: message,
          );
          if(!empty(_m)) {
            _error = true;
            returnMessageError(key, _m);
          }
        });
      }

    });
    _error = prepareValid(_error);
    if (_error) {
      _msg['message'] = 'Bạn vui lòng kiểm tra lại thông tin!'.lang();
    }
    return !_error;
  }

  _processValid({
    String key = '',
    dynamic message,
    dynamic value,
}){
    switch (key) {
      case 'required':
        if (empty(value, true)) {
          return message;
        }
        break;
      case 'equalTo': //['fields[fieldsosanh]', 'Thông báo']
        if (!empty(value)) {
          final RegExp _reg = new RegExp(r'fields\[([^\]]+)\]');
          final String _field = (_reg.hasMatch(message[0])) ? _reg
              .firstMatch(message[0])!.group(1) : message[0];
          if (message is List &&
              message.length == 2 &&
              message[0] is String &&
              fields.containsKey(_field) &&
              value != fields[_field]) {
            return message[1];
          }
        }
        break;
      case 'maxLength': //[Số lượng, 'Thông báo']
        if (message is List &&
            message.length == 2 &&
            message[0] is int && !empty(value) &&
            value.length > message[0]) {
          return message[1];
        }
        break;
      case 'minLength': //[Số lượng, 'Thông báo']
        if (message is List &&
            message.length == 2 &&
            message[0] is int && !empty(value) &&
            value.length < message[0]) {
          return message[1];
        }
        break;
      case 'dateLte': //['fields[field so sanh]', 'không được nhỏ hơn hoặc bằng']
      case 'dateGte': //['fields[field so sanh]', 'không được lớn hơn hoặc bằng']
      case 'dateGt': //['fields[field so sanh]', 'không được lớn hơn']
      case 'dateLt': //['fields[field so sanh]', 'không được nhỏ hơn']
        if (message is List &&
            message.length == 2 &&
            message[0] is String) {
          if (!_compareDate(value, message[0], key)) {
            return message[1];
          }
        }
        break;
      case 'email':
        if (!empty(value) && (!(value is String) ||
            (!value.toString().isEmailVN()))) {
          return message;
        }
        break;
      case 'password':
        if (!empty(value)) {
          if(value.length > 16 || value.length < 8){
            return (message is String)?message:'Mật khẩu phải có từ 8 đến 16 kí tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt';
          }
          final _reg = new RegExp(
              r'^.*(?=.{8,16})((?=.*[!@#$%^&*()\-_=+{};:,<.>]))(?=.*\d)((?=.*[a-z]))((?=.*[A-Z])).*$');
          if (!_reg.hasMatch(value)) {
            return (message is String)?message:'Mật khẩu phải có từ 8 đến 16 kí tự bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt';
          }
        }
        break;
      case 'invalidPassword':
        if (!empty(value)) {
          if(message is List){
            for(var i in message){
              if(i == value){
                return 'Mật khẩu không được đặt là "$i"';
              }

            }
          }
        }
        break;
      case 'phoneVN':
        if (!empty(value) && value is String &&
            !value.toString().isPhoneVN()) {
          return message;
        }
        break;
      case 'phoneLO':
        if (!empty(value) && value is String &&
            !value.toString().isPhoneLO()) {
          return message;
        }
        break;
      case 'regex':
        if (message is List && message.length == 2 && value != null) {
          final _regex = (message[0] is RegExp) ? message[0] : (new RegExp(
              message[0]));
          if (!_regex.hasMatch(value)) {
            return message[1];
          }
        }
        break;
      case 'min':
        if (message is List &&
            message.length == 2 &&
            message[0] is int && !empty(value)) {
          value = value is String ? int.tryParse(value) : value;
          if (value <= message[0]) {
            return message[1];
          }
        }
        break;
      case 'max':
        if (message is List &&
            message.length == 2 &&
            message[0] is int && !empty(value)) {
          value = value is String ? int.tryParse(value) : value;
          if (value > message[0]) {
            return message[1];
          }
        }
        break;
      default:
        if (message is Function && value != null) {
          var m = message(value);
          if (!empty(m)) {
            return m;
          }
        }
    }
  }

  @protected
  prepareValid(bool error) {
    return error;
  }

  bool _compareDate(var startDate, var endDate, [String compareType = 'lte']) {
    if (!empty(startDate) && !empty(endDate)) {
      final RegExp _reg = new RegExp(r'fields\[([^\]]+)\]');
      DateTime _start = startDate.toString().toDateTime(),
          _end;
      if (_reg.hasMatch(endDate)) {
        String endField = '${_reg.firstMatch(endDate)!.group(1)}';
        if (fields.containsKey(endField) && !empty(fields[endField])) {
          _end = fields['${_reg.firstMatch(endDate)!.group(1)}']
              .toString()
              .toDateTime();
        }
        else {
          return true;
        }
      } else {
        _end = endDate.toString().toDateTime();
      }
      switch (compareType) {
        case 'dateGte':
          if (_start.compareTo(_end) >= 0) {
            return true;
          }
          break;
        case 'dateGt':
          if (_start.isAfter(_end)) {
            return true;
          }
          break;
        case 'dateLt':
          if (_start.isBefore(_end)) {
            return true;
          }
          break;
        default:
          if (_start.compareTo(_end) <= 0) {
            return true;
          }
      }
    } else {
      return true;
    }
    return false;
  }

  void controllersDispose() {
    if (inputControllers != null) {
      inputControllers?.forEach((key, value) {
        value.close();
      });
    }
    if (inputObs != null) {
      inputObs!.forEach((key, value) {
        value.close();
      });
    }
  }

  back([dynamic result]) {
    if (mounted) appNavigator.pop(result);
  }

  @override
  void onClose() {
    controllersDispose();
    mounted = false;
    super.onClose();
  }
}
