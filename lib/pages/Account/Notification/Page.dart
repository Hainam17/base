import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class AccountNotificationPage extends StatelessPage {
  final String? service;
  final bool hideAppBar;
  const AccountNotificationPage({this.service, this.hideAppBar = false});

  @override
  Widget build(BuildContext context) {
    final _lib = Get.find<AppLib>();
    return Scaffold(
      appBar: (hideAppBar)?null:factories['header'](context, title: Text("Thông báo".lang()), actions:<Widget>[]),
      body: FutureBuilder<dynamic>(
          future: _lib.selectAllNotification(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              final _items = (snapshot.data != null && snapshot.data['items'] != null)
                  ?((snapshot.data['items'] is Map)?snapshot.data['items'].values.toList():snapshot.data['items'])
                  :null;
              final int _length = _items?.length??0;
              if (_length > 0) {
                  return ListView.builder(
                    itemCount: _length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (_, index) {
                    final _item = _items[index];
                    String? _image = (_item['image'] != null && _item['image'] != '')?_item['image'].toString().thumb(1.0, 50):null;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: (){
                          if(empty(_item['link'])) {
                            showDialog(
                                context: context,
                                builder: (_) =>
                                new AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:const BorderRadius.all(
                                          Radius.circular(10.0))
                                  ),
                                  content: AccountNotificationDetailPage(
                                      _item),
                                )
                            );
                          }else{
                            linkToRouter(_item['link']);
                          }
                        },
//                          child: Text('234324'),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              if(!empty(_image))Container(
                                width: 45,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  child: _image!.view(ratio: 1.0, width: 50),
                                ),
                              ),
                              if(!empty(_image))const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${!empty(_item['title']) ?(htmlDecode(_item['title'].toString()).stripTag()):'Thông báo'.lang()}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 5),
                                    TimeAgo(_item['createdTime'].toString().toDateTime())
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text('Không có dữ liệu'.lang()),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
