import 'package:flutter/material.dart';
import 'package:vhv_basic/widgets/Auth/Default.dart';
import 'package:vhv_basic/import.dart';
//@router
class AccountRegisterPage extends StatelessPage {
  const AccountRegisterPage();
  @override
  Widget build(BuildContext context) {
    return AuthDefault(
      isLogin: false,
    );
  }
}
