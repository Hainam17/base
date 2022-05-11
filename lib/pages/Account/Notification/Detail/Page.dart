import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/widgets/HtmlViewer.dart';

import 'Controller.dart';

class AccountNotificationDetailPage extends StatelessWidget {
  final dynamic params;

  const AccountNotificationDetailPage([this.params]):assert(params is Map, 'params is Map');

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountNotificationDetailController>(
      create: (_) => AccountNotificationDetailController(params!['id']),
      child: _AccountNotificationDetailPageContent(params),
    );
  }
}
class _AccountNotificationDetailPageContent extends StatelessWidget {
  final dynamic params;
  _AccountNotificationDetailPageContent([this.params]):assert(params is Map, 'params is Map');
  @override
  Widget build(BuildContext context) {
    final _controller = Provider.of<AccountNotificationDetailController>(context);
    if(_controller.isHide){
      return Padding(
        padding: const EdgeInsets.all(25),
        child: Text('Bạn không có quyền xem nội dung này!'.lang()),
      );
    }else{
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                color: Colors.blue,
                child: Row(
                  children: <Widget>[
                    Text('Chi tiết thông báo'.lang(), style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white)),
                    Spacer(),
                    InkWell(child: Icon(Icons.close, color: Colors.white.withOpacity(0.3)), onTap: (){
                      appNavigator.pop();
                    })
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    HTMLViewer(htmlDecode(!empty(_controller.params['content'])?_controller.params['content']: (!empty(params['content'])?params['content']:'')),
                      onLinkTap: (link){
                        linkToRouter(link);
                      }),
                    const SizedBox(height: 5),
                    HTMLViewer('${'Thời gian'.lang()} : ${date(!empty(_controller.params['createdTime'])?_controller.params['createdTime']: (!empty(params['createdTime'])?params['createdTime']:''), 'dd/MM/yyyy HH:mm:ss')}'),
                    const SizedBox(height: 5),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}

