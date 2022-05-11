import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingLib {
  Map<String, Box> boxes = {};
  Future init(dynamic tableNames) async {
    if (tableNames is String) {
      boxes[tableNames] = await Hive.openBox(tableNames);
    } else {
      for (var i = 0; i < tableNames.length; i++) {
        boxes[tableNames[i]] = await Hive.openBox(tableNames[i]);
      }
    }
  }

  Box? getBox(String boxName) {
    if (boxes.containsKey(boxName)) {
      return boxes[boxName];
    }
    return null;
  }

  bool containsKey(String tableName, dynamic key) {
    return getBox(tableName)!.containsKey(key);
  }

  Future put(String tableName, String id, dynamic data) async {
    return await getBox(tableName)!.put(id, data);
  }

  Future putAll(String tableName, Map entries) async {
    return await getBox(tableName)!.putAll(entries);
  }

  Future push(String tableName, dynamic data) async {
    return await getBox(tableName)!.add(data);
  }

  Future pushAll(String tableName, Iterable<dynamic> entries) async {
    return await getBox(tableName)!.addAll(entries);
  }

  dynamic getAt(String tableName, int index) {
    return getBox(tableName)?.getAt(index);
  }

  dynamic get(String tableName, dynamic key) {
    return getBox(tableName)?.get(key);
  }

  Future delete(String tableName, String id) async {
    return await getBox(tableName)?.delete(id);
  }

  Future clear(String tableName) async {
    return await getBox(tableName)?.clear();
  }

  ValueListenable listenable(tableName) {
    return getBox(tableName)!.listenable();
  }

  List getValues(tableName){
    return getBox(tableName)!.listenable().value.values.toList();
  }

  List getKeys(tableName){
    return getBox(tableName)!.listenable().value.keys.toList();
  }

  bool isNotEmpty(tableName) {
    if(getBox(tableName) != null) {
      return getBox(tableName)!.isNotEmpty;
    }
    return false;
  }

  bool isEmpty(tableName) {
    if(getBox(tableName) != null) {
      return getBox(tableName)!.isEmpty;
    }
    return true;
  }

  bool isOpen(tableName) {
    if(getBox(tableName) != null) {
      return getBox(tableName)!.isOpen;
    }
    return false;
  }
}

class Setting {
  String tableName;
  static late SettingLib storageLib;
  Setting([this.tableName = 'Config']);
  static Future init(dynamic tableNames) async {
    return storageLib.init(tableNames);
  }

  bool containsKey(dynamic key) {
    return storageLib.containsKey(tableName, key);
  }

  Future put(String id, dynamic data) async {
    return storageLib.put(tableName, id, data);
  }

  Future putAll(String tableName, Map entries) async {
    return storageLib.putAll(tableName, entries);
  }

  Future push(dynamic data) async {
    return storageLib.push(tableName, data);
  }

  Future pushAll(String tableName, Iterable<dynamic> entries) async {
    return storageLib.pushAll(tableName, entries);
  }

  dynamic getAt(int index) {
    return storageLib.getAt(tableName, index);
  }

  List getKeys() {
    return storageLib.getKeys(tableName);
  }

  List getValues() {
    return storageLib.getValues(tableName);
  }

  dynamic get(dynamic key) {
    return storageLib.get(tableName, key);
  }

  Future delete(String id) async {
    return storageLib.delete(tableName, id);
  }

  Future clear() async {
    return storageLib.clear(tableName);
  }

  dynamic operator [](String key) {
    return storageLib.get(tableName, key);
  }

  ValueListenable listenable() {
    return storageLib.listenable(tableName);
  }

  bool get isNotEmpty => storageLib.isNotEmpty(tableName);
  bool get isEmpty => storageLib.isEmpty(tableName);
  bool get isOpen => storageLib.isOpen(tableName);
}
