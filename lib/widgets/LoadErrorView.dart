import 'package:flutter/material.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/global.dart';

class LoadErrorView extends StatelessWidget {
  final VoidCallback? reload;
  const LoadErrorView({Key? key, this.reload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 340
        ),
        child: Card(
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_outlined, size: 45, color: Colors.deepOrange),
                const SizedBox(height: 20),
                Text('Đã xảy ra lỗi trong quá trình tải dữ liệu.\n Bạn có muốn tải lại?'.lang(), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(onPressed: (){
                      appNavigator.pop();
                    },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Colors.grey),
                        ),
                        child: Text('Thoát'.lang())),
                    TextButton.icon(onPressed: reload,
                        icon: const Icon(Icons.replay), label: Text('Tải lại'.lang())),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
