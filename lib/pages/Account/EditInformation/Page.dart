import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vhv_basic/form.dart';
import 'package:vhv_basic/import.dart';
import 'Controller.dart';

class AccountEditInformationPage extends StatelessPage {
  const AccountEditInformationPage();
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: factories['header'](context,
              title: Text('Chỉnh sửa thông tin'.lang())),
          body: SingleChildScrollView(
            child: GetBuilder<AccountEditInformationController>(
                init: AccountEditInformationController(),
                builder: (_model) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child:  Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              children: <Widget>[
                                //if(_imageBase64 != null)Image.memory(base64Decode(_imageBase64)),
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: ClipOval(
                                    child: Container(
                                      color: Colors.white,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: <Widget>[
                                          Avatar(
                                            _model['fullName'],
                                            width: 150,
                                            image: _model['image'],
                                          ),
                                          SizedBox(
                                              height: 30,
                                              width: 40,
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(
                                                              Color.fromRGBO(
                                                                  0,
                                                                  0,
                                                                  0,
                                                                  0.5)),
                                                      textStyle: MaterialStateProperty.all(
                                                          TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      padding: MaterialStateProperty.all(
                                                          const EdgeInsets.symmetric(
                                                              vertical: 2,
                                                              horizontal: 5))),
                                                  child: const Icon(
                                                    Icons.camera_alt,
                                                    size: 22,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    _model['image'] =
                                                        await selectImage(
                                                            width: (_width *
                                                                    2)
                                                                .ceil());
                                                    _model.update();
                                                  }))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Hồ sơ của tôi".lang(),
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                  "Quản lý hồ sơ thông tin hồ sơ để bảo mật tài khoản"
                                      .lang()),
                            ],
                          ),
                        ),
                        FormGroup(
                          'Họ và tên'.lang(),
                          required: true,
                          child: TextFormField(
                            onChanged: (value) {
                              _model['fullName'] = value;
                            },
                            initialValue: _model['fullName'] ?? '',
                            decoration: _inputDecoration(
                              errorText: _model.errorMessages['fullName'],
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        (_model['email'] == null || _model['email'] == '')
                            ? FormGroup(
                                'Email',
                          required: true,
                                child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    _model['email'] = value;
                                  },
                                  initialValue: _model['email'] ?? '',
                                  decoration: _inputDecoration(
                                    errorText: _model.errorMessages['email'],
                                  ),
                                ),
                              )
                            : FormGroup(
                                'Email',
                                required: true,
                                child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    _model['email'] = value;
                                  },
                                  enabled: false,
                                  initialValue: _model['email'] ?? '',
                                  decoration: _inputDecoration(enabled: false),
                                ),
                              ),
                       
                        FormGroup(
                          'Số điện thoại'.lang(),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            initialValue: _model['phone'] ?? '',
                            onChanged: (value) {
                              _model['phone'] = value;
                            },
                            decoration: _inputDecoration(
                                errorText: _model.errorMessages['phone']),
                          ),
                        ),
                       
                        FormGroup(
                          'Giới tính'.lang(),
                          child: FormSelect(
                              value: !empty(_model['gender'])
                                  ? _model['gender']
                                  : '',
                              items: {'1': 'Nam'.lang(), '2': 'Nữ'.lang()},
                              decoration: _inputDecoration(),
                              description: 'Chọn',
                              onChanged: (val) {
                                _model['gender'] = val;
                              }),
                        ),
                       
                        FormGroup(
                          'Ngày sinh'.lang(),
                          required: true,
                          child: FormDatePicker(
                            dateFormat: DateFormat("dd/MM/yyyy"),
                            lastDate: new DateTime.now(),
                            onDateSelected: (DateTime date) {
                              _model['birthDate'] = date.toStr();
                            },
                            selectedDate: !empty(_model['birthDate'])
                                ? _model['birthDate'].toString().toDateTime()
                                : null,
                            decoration: _inputDecoration(errorText: _model.errorMessages['birthDate']),
                          ),
                        ),
                       
                        FormGroup(
                          'Địa chỉ'.lang(),
                          child: TextFormField(
                            initialValue: !empty(_model['address'])
                                ? _model['address']
                                : '',
                            onChanged: (value) {
                              _model['address'] = value;
                            },
                            decoration: _inputDecoration(
                                errorText: _model.errorMessages['address']),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Center(
                            child: ButtonFlat(
                              color: Colors.blue,
                              onPressed: (connectionStatus !=
                                      ConnectivityStatus.offline)
                                  ? () async {
                                      final _result = await _model.submit();
                                      if (_result['message'] != null) {
                                        showMessage(
                                          _result['message'],
                                          type: _result['status'],
                                        );
                                        if (_result['status'] == 'SUCCESS') {
                                          appNavigator.pop();
                                        }
                                      }
                                      if (!empty(_model.errorMessages)) {
                                        _model.update();
                                      }
                                    }
                                  : () {
                                      showMessage(
                                        'Bạn vui lòng kiểm tra kết nối mạng!'
                                            .lang(),
                                        type: 'FAIL',
                                      );
                                    },
                              child: Text(
                                'Hoàn tất'.lang(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )),
    );
  }

  InputDecoration _inputDecoration(
      {String? labelText, String? hintText, String? errorText, bool enabled = true}) {
    return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        enabled: enabled,filled: !enabled ? true : false,
        fillColor: !enabled ? Colors.grey[200] : null,
        errorStyle: const TextStyle(color: Colors.red),
        contentPadding: const EdgeInsets.all(10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        labelStyle: TextStyle(
            color: Theme.of(currentContext).textTheme.bodyText1!.color));
  }
}
