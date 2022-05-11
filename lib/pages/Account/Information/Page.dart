import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class AccountInformationPage extends StatelessWidget {
  const AccountInformationPage();
  @override
  Widget build(BuildContext context) {
    const List _items = [
      {
        'code': 'fullName',
        'title': 'Họ và tên'
      },
      {
        'code': 'phone',
        'title': 'Số điện thoại'
      },
      {
        'code': 'email',
        'title': 'Email'
      },
      {
        'code': 'birthDate',
        'title': 'Ngày sinh'
      },
      {
        'code': 'gender',
        'title': 'Giới tính'
      },
      {
        'code': 'address',
        'title': 'Địa chỉ'
      }
    ];
    return Scaffold(
      appBar: factories['header'](context, title: Text('Thông tin cá nhân'.lang()), actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: (){
            appNavigator.pushNamedAndRemoveUntil('/Account/EditInformation');
          },
        )
      ]),
      body: ListView(
        padding: EdgeInsets.all(paddingBase),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Avatar(account['fullName'], image: account['image'], width: 150),
            ),
          )
        ]..addAll(_items.map<Widget>((e){
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: new TextSpan(
              text: '${e['title']}: ',
              children: [
                TextSpan(
                  text: (e['code'] == 'gender')?(account[e['code']] == '1'?'Nam':(account[e['code']] == '2'?'Nữ':'Khác')):account[e['code']],
                  style:const TextStyle(
                    fontWeight: FontWeight.w500
                  )
                ),
              ],
              style: Theme.of(context).textTheme.subtitle1!.copyWith(fontWeight: FontWeight.normal)
            ),
          )
          );
        }).toList()),
      ),
    );
  }
}
