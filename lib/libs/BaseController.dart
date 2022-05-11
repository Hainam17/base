import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:vhv_basic/import.dart';

class BaseController {
  Map<String, String>? _captcha;
  Map<String, dynamic>? fields;
  Map<String, dynamic>? extraParams;
  Map<String, dynamic>? errorMessages = {};
  final bool useFields;
  String? submitService = '';
  BaseController(
      {this.submitService,
      this.fields,
      this.extraParams,
      this.rules,
      this.useFields: true,
      List<String>? controllerNames}) {
    fields = fields ?? {};
    createController(controllerNames);
  }
  bool _isSubmitting = false;
  Map<String, Map<String, dynamic>>? rules = {};
  Map<String, String> _msg = {
    'status': 'FAIL',
    'message': 'Có lỗi xảy ra.'.lang()
  };
  Map<String, StreamController<String>> inputControllers = {};
  createController(List<String>? inputNames) {
    inputNames?.forEach((element) {
      inputControllers[element] = new StreamController();
    });
  }

  dynamic operator [](String name) {
    if (name.endsWith('Stream') &&
        inputControllers.length > 0 &&
        inputControllers.containsKey(name.substring(0, name.length - 6))) {
      return inputControllers[name.substring(0, name.length - 6)]!.stream;
    }
    if (fields == null) fields = <String, dynamic>{};
    if (fields != null && fields!.containsKey(name)) {
      return fields![name];
    }
  }

  void operator []=(String name, value) {
    if (name == 'captcha') {
      _captcha = value;
    }
    if (fields == null) fields = <String, dynamic>{};
    if (fields != null) {
      if (errorMessages!.containsKey(name)) {
        errorMessages!.remove(name);
      }
      fields![name] = (value is String)?value.trim():value;
    }
  }

  submit() async {
    errorMessages = {};
    if (!_isSubmitting) {
      _isSubmitting = true;
      if (await checkValid(fields!) == true) {
        await _send();
      } else {
        await onErrorValidation();
        _isSubmitting = false;
      }
      return _msg;
    }
  }

  @protected
  onSuccess(response) async {
    _msg['message'] = (response is Map && response['message'] != null)
        ? response['message']
        : 'Cập nhật thành công';
  }

  @protected
  onFail(response) async {
    if (response == null) {
      _msg['message'] = 'Có lỗi xảy ra.';
    } else if (response['message'] != null) {
      _msg['message'] = response['message'];
    }
  }

  @protected
  onErrorValidation() async {
    _msg.putIfAbsent('status', () => 'FAIL');
    _msg.putIfAbsent(
        'message', () => 'Bạn vui lòng kiểm tra lại thông tin!'.lang());
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
    Map<String, dynamic> submitFields;
    final _fields = <String, dynamic>{};
    fields!.forEach((key, value) {
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
      submitFields = (_fields..addAll(extraParams ?? {}));
    }
    if (_captcha != null) submitFields.addAll(_captcha!);
    final _res = await call(submitService!, params: submitFields);
    _isSubmitting = false;
    await onSend(_res);
  }

  _returnMessageError(key, message) {
    errorMessages![key] = message;
    if (inputControllers.length > 0 && inputControllers.containsKey(key)) {
      inputControllers[key]!
          .addError((message is String) ? message.lang() : message);
    } else {}
  }

  Future<bool> checkValid(Map<String, dynamic> fields) async {
    bool _error = false;
    inputControllers.forEach((key, value) {
      value.add('');
    });
    rules?.forEach((key, subRules) {
      String value = (fields.containsKey(key) && fields[key] != null)
          ? fields[key].toString()
          : '';
      subRules.forEach((subKey, message) {
        switch (subKey) {
          case 'required':
            if (empty(value)) {
              _returnMessageError(key, message);
              _error = true;
            }
            break;
          case 'equalTo':
            if (message is List &&
                message.length == 2 &&
                message[0] is String &&
                fields.containsKey(message[0]) &&
                value != fields[message[0]]) {
              _returnMessageError(key, message[1]);
              _error = true;
            }
            break;
          case 'maxLength':
            if (message is List &&
                message.length == 2 &&
                message[0] is int &&
                value.length > message[0]) {
              _returnMessageError(key, message[1]);
              _error = true;
            }
            break;
          case 'minLength':
            if (message is List &&
                message.length == 2 &&
                message[0] is int &&
                value.length < message[0]) {
              _returnMessageError(key, message[1]);
              _error = true;
            }
            break;
          case 'email':
            if (value.trim() != '' && !value.isEmail) {
              _returnMessageError(key, message);
              _error = true;
            }
            break;
          case 'phoneVN':
            if (value.trim() != '' && !value.isPhoneVN()) {
              _returnMessageError(key, message);
              _error = true;
            }
            break;
          case 'regex':
            if (message is List && message.length == 2) {
              final _regex = new RegExp('${message[0]}');
              if (!_regex.hasMatch(value)) {
                _returnMessageError(key, message[1]);
                _error = true;
              }
            }
            break;
          default:
            if (message is Function) {
              var m = message(value);
              if (m != '' && m != null) {
                _returnMessageError(key, m);
                _error = true;
              }
            }
        }
      });
    });
    if (_error) {
      _msg['message'] = 'Bạn vui lòng kiểm tra lại thông tin!'.lang();
    }
    return !_error;
  }

  void controllersDispose() {
    inputControllers.forEach((key, value) {
      value.close();
    });
  }

  void dispose() {
    controllersDispose();
  }
}
