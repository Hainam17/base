import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class InAppUpdate extends StatelessWidget {
  final Map info;

  const InAppUpdate(this.info, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Cập nhật ứng dụng?'.lang(), style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500
          )),
          const SizedBox(height: 15),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đã có bản cập nhật mới! Phiên bản ${info['new']['version']}(${info['new']['buildNumber']}) hiện đã sẵn sàng - phiên bản hiện tại ${info['current']['version']}(${info['current']['buildNumber']}).', style: TextStyle(
                fontSize: 17,
              )),
              const SizedBox(height: 10),
              Text('Bạn có muốn cập nhật luôn?'.lang(), style:const TextStyle(
                fontSize: 17,
              ))
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: exitApp,
                child: Text(lang('Thoát ứng dụng'))
              ),
              const SizedBox(width: 15),
              ButtonRaised(
                color: Colors.blue,
                textColor: Colors.white,
                child: Text(lang('Cập nhật ngay')),
                onPressed: (){
                  urlLaunch(info['link']);
                  // appNavigator.pop();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
