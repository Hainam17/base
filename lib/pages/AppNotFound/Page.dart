import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/widgets/NoData.dart';

class AppNotFoundPage extends StatelessWidget {
  final Map? params;

  const AppNotFoundPage({Key? key, this.params}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NoData(
              msg: params!['message'],
            ),
          ),
          if(account.isLogin())TextButton(onPressed: (){
            logout();
          }, child: Text(
            lang('Đăng xuất')
          ))
        ],
      ),
    );
  }
}
