import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'Controller.dart';
import 'package:vhv_basic/form.dart';

class AccountChangePasswordPage extends StatelessWidget {
  final bool? hasOldPassword;
  final String? submitService;
  final Map? param;

  const AccountChangePasswordPage(
      {Key? key, this.hasOldPassword = true, this.submitService, this.param})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    InputDecoration _inputDecoration({String? label,
      String? hintText,
      String? errorText,
      Widget? suffixIcon}) {
      return InputDecoration(
          hintText: (hintText != null) ? hintText.lang() : null,
          labelText: (label != null) ? label.lang() : null,
          errorText: (errorText != null) ? errorText.lang() : null,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.blue, width: 1),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          errorMaxLines: 4,
          labelStyle:
          TextStyle(color: Theme
              .of(context)
              .textTheme
              .bodyText1!
              .color));
    }

    return GetBuilder<ChangePasswordController>(
        init: ChangePasswordController(
            hasOldPassword: hasOldPassword!,
            submitService: submitService ?? 'Member.User.changePassword',
            param: param
        ),
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            behavior: HitTestBehavior.opaque,
            child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text('?????i m???t kh???u'.lang(),
                          style: const TextStyle(fontSize: 26)),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if(!hasOldPassword!)
                              RichText(
                                textAlign: TextAlign.left,
                                text: new TextSpan(
                                    text: 'T??i kho???n'.lang(),
                                    children: [
                                      TextSpan(
                                          text: ': ${param!['code'] ??
                                              param!['title']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                    ],
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(fontWeight: FontWeight.normal)
                                ),
                              ).paddingOnly(bottom: 10),

                            if (hasOldPassword!)
                              FormGroup(
                                'M???t kh???u c??',
                                required: true,
                                child: TextFormField(
                                  autofocus: true,
                                  obscureText: controller.passwordVisibleOld,
                                  decoration: _inputDecoration(
                                    //hintText: 'M???t kh???u c??',
                                    // label: 'M???t kh???u c??',
                                    errorText:
                                    controller.errorMessages['oldPassword'],
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          controller.passwordVisibleOld
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 20,
                                          color:
                                          Theme
                                              .of(context)
                                              .disabledColor),
                                      onPressed: () {
                                        controller.passwordVisibleOld =
                                        !controller.passwordVisibleOld;
                                        controller.update();
                                      },
                                    ),
                                  ),
                                  onChanged: (val) {
                                    controller['oldPassword'] = val;
                                  },
                                ),
                              ),
                            // if (hasOldPassword!)
                            //   SizedBox(
                            //     height: 15,
                            //   ),
                            FormGroup(
                              'M???t kh???u m???i',
                              required: true,
                              child: TextFormField(
                                obscureText: controller.passwordVisibleNew,
                                autofocus: true,
                                decoration: _inputDecoration(
                                  //hintText: 'M???t kh???u m???i',
                                  // label: 'M???t kh???u m???i',
                                  errorText:
                                  controller.errorMessages['password'],
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        controller.passwordVisibleNew
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 20,
                                        color: Theme
                                            .of(context)
                                            .disabledColor),
                                    onPressed: () {
                                      controller.passwordVisibleNew =
                                      !controller.passwordVisibleNew;
                                      controller.update();
                                    },
                                  ),
                                ),
                                onChanged: (val) {
                                  controller['password'] = val;
                                },
                              ),
                            ),
                            // SizedBox(
                            //   height: 15,
                            // ),
                            FormGroup(
                              'Nh???p l???i m???t kh???u m???i',
                              required: true,
                              child: TextFormField(
                                obscureText:
                                controller.passwordVisibleConfluent,
                                decoration: _inputDecoration(
                                  //hintText: 'Nh???p l???i m???t kh???u',
                                  // label: 'Nh???p l???i m???t kh???u m???i',
                                  errorText: controller
                                      .errorMessages['confirmPassword'],
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        controller.passwordVisibleConfluent
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        size: 20,
                                        color: Theme
                                            .of(context)
                                            .disabledColor),
                                    onPressed: () {
                                      controller.passwordVisibleConfluent =
                                      !controller.passwordVisibleConfluent;
                                      controller.update();
                                    },
                                  ),
                                ),
                                onChanged: (val) {
                                  controller['confirmPassword'] = val;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            DefaultTextStyle(
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(color: Colors.red),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'L??u ??'.lang() + ':',
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '1. ' +
                                          'M???t kh???u m???i c?? ????? d??i t???i thi???u 8 k?? t???'
                                              .lang(),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                        '2. ' +
                                            'M???t kh???u m???i ph???i bao g???m c??? ch??? hoa, ch??? th?????ng, s??? v?? k?? t??? ?????c bi???t'
                                                .lang()
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      '3. ' +
                                          'M???t kh???u m???i kh??ng ch???a t??n ????ng nh???p ho???c email'
                                              .lang(),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      '4. ' +
                                          'M???t kh???u m???i kh??ng ???????c ?????t l?? Demo@123, 123456aA@, 12345678aA@'
                                              .lang(),
                                    ),
                                  ]),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          Colors.grey),
                                      textStyle: MaterialStateProperty.all(
                                          const TextStyle(
                                              color: Colors.white))),
                                  child: Text('H???y b???'.lang()),
                                  onPressed: () {
                                    appNavigator.pop();
                                  },
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await controller.submit();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all(Colors.blue),
                                      textStyle: MaterialStateProperty.all(
                                          const TextStyle(color: Colors.white))
                                  ),
                                  child: Text('C???p nh???t'.lang()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          );
        });
  }
}
