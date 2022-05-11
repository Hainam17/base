import 'package:flutter/material.dart';
import 'package:vhv_basic/form.dart' show FormCaptcha, FormRadio;
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/Form/TextField.dart';
import 'Controller.dart';
import 'package:animations/animations.dart';

class AuthForgotPasswordDefault extends StatelessWidget {
  final Color? primaryColor;

  const AuthForgotPasswordDefault({Key? key, this.primaryColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<AuthForgotPasswordController>(
        init: AuthForgotPasswordController(),
        builder: (_model){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: _model.reverse,
                transitionBuilder: (Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  return SharedAxisTransition(
                    child: child,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                  );
                },
                child: (_model.index == 0) ? _AccountForgotPasswordStepAccount()
                    : ((_model.index == 1) ? _AccountForgotPasswordStepAuth()
//                        : ((_model.index == 2) ? _AccountForgotPasswordStepChangePass()
                    : _AccountForgotPasswordStepSuccess()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: LayoutBuilder(
                  builder: (_, BoxConstraints contrast) {
                    final _width = (_model.index > 0) ? contrast.maxWidth : 200.0;
                    return AnimatedContainer(
                      width: _width,
                      duration: Duration(milliseconds: 100),
                      child: Row(
                        mainAxisAlignment: (_model.index > 0) ? MainAxisAlignment
                            .spaceBetween : MainAxisAlignment.center,
                        children: <Widget>[
                          (_model.index > 0 && _model.index < 2) ? TextButton(
                            onPressed: _model.backStep,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.blue),
                              foregroundColor: MaterialStateProperty.all(
                                  Colors.white)),
                            child: Text('Trở lại'.lang(), overflow: TextOverflow
                                .ellipsis, maxLines: 1),
                          ) : const SizedBox.shrink(),
                          (_model.index < 2) ? ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    primaryColor ?? Theme
                                        .of(context)
                                        .colorScheme
                                        .primary),
                                textStyle: MaterialStateProperty.all(
                                    TextStyle(color: Theme
                                        .of(context)
                                        .colorScheme
                                        .onPrimary)),
                                elevation: MaterialStateProperty.all(0)
                            ),
                            onPressed: _model.next,
                            child: Text('Tiếp tục'.lang(), overflow: TextOverflow
                                .ellipsis, maxLines: 1),
                          ) : SizedBox(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountForgotPasswordStepSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .cardColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
          child: Text('Bạn đã đổi mật khẩu thành công'.lang(),
            style: TextStyle(fontSize: Theme
                .of(context)
                .textTheme
                .headline6!
                .copyWith(fontSize: 17)
                .fontSize), textAlign: TextAlign.center)
      ),
    );
  }
}

class _AccountForgotPasswordStepAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _model = Get.find<AuthForgotPasswordController>();
    return Container(
        color: Theme
            .of(context)
            .cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                'Tài khoản'.lang(),
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: FormTextField(
                onChanged: (val) => _model['username'] = val,
                value: _model['username'] ?? '',
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  errorText: _model.errorMessages['username'],
                  errorMaxLines: 2,
                  labelText: (hasComponent('Project.STDV'))?'Tài khoản'.lang():'Tài khoản hoặc email'.lang(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text('Bạn muốn nhận được mã OTP bằng cách nào?'.lang())),
            const SizedBox(height: 10),
            FormRadio(
              value: _model['protocol'] ?? 'email',
              listValues: {
                if(!hasComponent('Project.STDV'))'email': 'Email'.lang(),
                if(hasComponent('Software.CRM.Marketing.Notification.SMS'))'phone': 'Số điện thoại'.lang(),
              },
              onChanged: (val) {
                _model['protocol'] = val;
              },
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: FormCaptcha(
                onChanged: (data) {
                  _model.captcha = data;
                },
                buildReloadCaptcha: (reload){
                  _model.reloadCaptcha = reload;
                },
                focusNode: _model.captchaFocusNode,
                decoration: _inputDecoration(
                    errorText: _model.errorMessages['captcha'],
                    labelText: 'Mã xác thực'.lang(),
                  errorMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(height: 15)
          ],
        )
    );
  }
}

class _AccountForgotPasswordStepAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _model = Get.find<AuthForgotPasswordController>();
    return Container(
        color: Theme
            .of(context)
            .cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Mã OTP'.lang(),
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6,
            ),
            const SizedBox(height: 20),
            FormTextField(
              onChanged: (val) => _model['otp'] = val,
              value: _model['otp'] ?? '',
              decoration: _inputDecoration(
                helperText: _model.helper['otp'].toString().replaceAll(RegExp(r'verification|xác thực'), 'OTP'),
                errorText: _model.errorMessages['otp'],
                labelText: 'Nhập mã OTP'.lang(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        )
    );
  }
}

class _AccountForgotPasswordStepChangePass extends StatefulWidget {
  @override
  __AccountForgotPasswordStepChangePassState createState() =>
      __AccountForgotPasswordStepChangePassState();
}

class __AccountForgotPasswordStepChangePassState
    extends State<_AccountForgotPasswordStepChangePass> {
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    final _model = Get.find<AuthForgotPasswordController>();
    return Container(
        color: Theme
            .of(context)
            .cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Mật khẩu mới'.lang(),
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6,
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: passwordVisible,
              onChanged: (val) => _model['password'] = val,
              initialValue: _model['password'] ?? '',
              decoration: _inputDecoration(
                helperText: _model.helper['password']!,
                errorText: _model.errorMessages['password'],
                errorMaxLines: 3,
                labelText: 'Nhập mật khẩu'.lang(),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: confirmPasswordVisible,
              onChanged: (val) => _model['confirmPassword'] = val,
              initialValue: _model['confirmPassword'] ?? '',
              decoration: _inputDecoration(
                helperText: _model.helper['confirmPassword']!,
                errorText: _model.errorMessages['confirmPassword'],
                errorMaxLines: 3,
                labelText: 'Nhập lại mật khẩu',
                suffixIcon: IconButton(
                  icon: Icon(
                    confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      confirmPasswordVisible = !confirmPasswordVisible;
                    });
                  },
                ),
              ),

            ),
            const SizedBox(height: 20),
          ],
        )
    );
  }
}

InputDecoration _inputDecoration(
    {String? errorText, String? labelText, String? hintText, String? helperText,
      Widget? suffixIcon, int errorMaxLines = 1}) {
  return InputDecoration(
    errorText: (errorText!= null &&  errorText != '') ? errorText.lang() : null,
    labelText: (labelText!= null &&  labelText != '') ? labelText.lang() : null,
    helperText: (helperText!= null &&  helperText != '') ? helperText.lang() : null,
    suffixIcon: suffixIcon,
    helperMaxLines: 3,errorMaxLines: errorMaxLines,
    border: const OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: const BorderRadius.all(Radius.circular(50))
    ),
    errorBorder: const OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: const BorderRadius.all(Radius.circular(50))
    ),
    contentPadding: const EdgeInsets.all(15),
    hintText: (hintText != '') ? hintText : '',
  );
}