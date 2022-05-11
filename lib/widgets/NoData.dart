import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
class NoData extends StatelessWidget {
  final String? msg;
  final IconData? iconData;
  final Widget? icon;

  const NoData({this.msg, this.iconData, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(!empty(iconData))Opacity(opacity: 0.7,
                child: Icon(iconData??Icons.notes, size: 80)),
            if(empty(iconData))(icon != null)?icon!:SvgViewer('assets/icons/ic_nodata.svg', package: 'vhv_basic'),
            const SizedBox(height: 10),
            Text('${msg != null && msg != '' ? msg : 'Không có dữ liệu'}'.lang(),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
