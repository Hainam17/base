// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
export 'package:permission_handler/permission_handler.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper/system.dart';


class PermissionLib{
  Future<bool> request(Permission permission, [VoidCallback? onOpenSetting]) async {
    final _permissionStatus = await permission.request();
    if (_permissionStatus == PermissionStatus.granted) {
      return true;
    }else{
      await _showDialog(_getTitle(permission)!, onOpenSetting);
    }
    return false;
  }

  Future<bool> requests(List<Permission> permissions, [VoidCallback? onOpenSetting])async{
    final Map<Permission, PermissionStatus> _permissionsStatus = await permissions.request();
    List<String> requestTitles = [];
    bool _res = true;
    await Future.forEach(_permissionsStatus.entries, (MapEntry element)async{
      if(element.value != PermissionStatus.granted){
        requestTitles.add(_getTitle(element.key)!);
        _res = false;
      }
    }).then((value)async{
      if(!empty(requestTitles)){
        await _showDialog(requestTitles.join(', '), onOpenSetting);
      }
    });
    return _res;
  }

  _showDialog(String title, [VoidCallback? onOpenSetting])async{
    await appNavigator.showDialog(title: 'Thông báo',
        middleText: 'Bạn cần cấp quyền truy cập "%s" để tiếp tục.'.lang(args: [title]),
      onConfirm: ()async{
        appNavigator.pop();
        onOpenSetting!();
        await openAppSettings();
      },
      textConfirm: 'Đồng ý'.lang(),
      // textCancel: 'Hủy'.lang(),
      confirmTextColor: Colors.white
    );
  }
  String? _getTitle(Permission permission){
    switch(permission.toString()){
      case 'Permission.camera':
        return 'Máy ảnh'.lang();
        break;
      case 'Permission.storage':
        return 'Bộ nhớ'.lang();
        break;
      case 'Permission.contacts':
        return 'Danh bạ'.lang();
        break;
      case 'Permission.microphone':
        return 'Micro'.lang();
        break;
      case 'Permission.calendar':
        return 'Lịch'.lang();
        break;
      case 'Permission.notification':
        return 'Thông báo'.lang();
        break;
      case 'Permission.mediaLibrary':
        return 'Thư viện'.lang();
        break;
      case 'Permission.photos':
        return 'Thư viện ảnh'.lang();
        break;
      default:
        return null;
    }
  }
}