import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper/system.dart';

class SettingLib {
  GetStorage getBox(String boxName) {
    return GetStorage(boxName);
  }

  bool containsKey(String tableName, dynamic key) {
    return getBox(tableName).hasData(key);
  }

  init(String tableName)async{
    return await GetStorage.init(tableName);
  }
  Future put(String tableName, String id, dynamic data) async {
    final _res = await getBox(tableName).write(id, data);
    return _res;
  }

  dynamic get(String tableName, dynamic key) {
    return getBox(tableName).read(key);
  }
  Future deleteAll(String tableName) async {
    return await getBox(tableName).erase();
  }
  Future delete(String tableName, String id) async {
    return await getBox(tableName).remove(id);
  }
  Future clear(String tableName) async {
    return await getBox(tableName).erase();
  }
  dynamic getValues(String tableName) {
    return getBox(tableName).getValues();
  }
  dynamic getKeys(String tableName)  {
    return getBox(tableName).getKeys();
  }
  listenKey(String tableName, String key, Function(dynamic) callback){
    return getBox(tableName).listenKey(key, callback);
  }
  ValueListenable listenable(tableName) {
    return getBox(tableName).listenable;
  }

}

class Setting {
  String tableName;
  static SettingLib? storageLib;
  Setting([this.tableName = 'Config']);
  static Future init(dynamic tableName) async {
    if(tableName is String) {
      await storageLib!.init(tableName);
    }else if(tableName is List){
      await Future.forEach(tableName, (element)async{
        await storageLib!.init(element as String);
      });
    }
    return true;
  }
  bool get isOpen => _isOpen();

  bool _isOpen(){
    if(tableName == 'Config')return true;
    return inArray(tableName, factories['boxStorage']);
  }

  bool containsKey(dynamic key) {
    return storageLib!.containsKey(tableName, key);
  }

  Future put(String id, dynamic data) async {
    return await storageLib!.put(tableName, id, data);
  }


  dynamic get(dynamic key) {
    return storageLib!.get(tableName, key);
  }

  Future deleteAll() async {
    return await storageLib!.deleteAll(tableName);
  }

  Future delete(String id) async {
    return await storageLib!.delete(tableName, id);
  }

  Future clear() async {
    return await storageLib!.clear(tableName);
  }


  dynamic operator [](String key) {
    return  storageLib!.get(tableName, key);
  }
  dynamic getValues() {
    return storageLib!.getValues(tableName);
  }
  dynamic getKeys() {
    return storageLib!.getKeys(tableName);
  }

  ValueListenable listenable() {
    return storageLib!.listenable(tableName);
  }

  listenKey(String key, Function(dynamic) callback){
    return storageLib!.listenKey(tableName, key, callback);
  }
}
