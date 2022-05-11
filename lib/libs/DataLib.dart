import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:vhv_basic/helper/system.dart';

class Data {
  DatabaseFactory dbFactory = databaseFactoryIo;
  static Database? db;
  String? collection;
  StoreRef? store;
  int totalItems = 0;
  dynamic options = {
    'itemsPerPage': 20,
    'orderBy': 'id ASC',
    'skip': 0,
    'pageNo': 1
  };
  Data([String? collection]) {
    this.collection = collection;
  }
  static var intCollections = ['User', 'Category'];

  connect() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String dbPath = appDocDirectory.path + '/colombo.db';

    if (db == null || db is List) {
      db = await dbFactory.openDatabase(dbPath);
      log('Connect $dbPath ${jsonEncode(db)}');
    }
    if (db != null) {
      if (intCollections.contains(collection)) {
        store = intMapStoreFactory.store(collection);
      } else {
        store = stringMapStoreFactory.store(collection);
      }
    }
  }

  void close() async {
    await db!.close();
  }

  Filter _convertKeyFilters(key, value) {
    if (value is Map) {
      if (value.containsKey('\$eq')) {
        return Filter.equals(key, value['\$eq']);
      }
      if (value.containsKey('\$ne')) {
        return Filter.notEquals(key, value['\$ne']);
      }
      if (value.containsKey('\$lt')) {
        return Filter.lessThan(key, value['\$lt']);
      }
      if (value.containsKey('\$lte')) {
        return Filter.lessThanOrEquals(key, value['\$lte']);
      }
      if (value.containsKey('\$gt')) {
        return Filter.greaterThan(key, value['\$gt']);
      }
      if (value.containsKey('\$gte')) {
        return Filter.greaterThanOrEquals(key, value['\$gte']);
      }
      if (value.containsKey('\$in')) {
        return Filter.inList(key, value['\$in']);
      }
      if (value.containsKey('\$regex')) {
        return Filter.matches(key, value['\$regex']);
      }
    }
    return Filter.equals(key, value);
  }

  Filter? convertFilters([Map? filters]) {
    if (filters == null) {
      return null;
    }
    if (filters.isEmpty) {
      return null;
    }
    if (filters.length > 1) {

      List<Filter> fq = [];
      filters.forEach((key, value) {
        fq.add(convertFilters({key: value})!);
      });
      return Filter.and(fq);
    }

    if (filters.containsKey('\$and') || filters.containsKey('\$or')) {
      List<Filter> fq = [];
      filters.values.first.forEach((key, value) {
        fq.add(convertFilters(value)!);
      });
      if (filters.containsKey('\$and')) {
        return Filter.and(fq);
      }
      return Filter.or(fq);
    }
    return _convertKeyFilters(filters.keys.first, filters.values.first);
  }

  List<SortOrder> convertSortOrder(sortOrder) {
    if (sortOrder is String) {
      sortOrder = sortOrder.split(',');
    }
    var sl = <SortOrder>[];
    for (var i = 0; i < sortOrder.length; i++) {
      var value = sortOrder[i];
      var values = value.trim().split(' ');
      values.removeWhere((element) => element == '');
      sl.add(SortOrder(values[0], (values[1].toUpperCase() != 'DESC')));
    }

    return sl;
  }

  select(id) async {
    await connect();
    if (store != null) {
      if (id is int || id is String) {
        var result = await store!.record(id).get(db!);
        return result;
      } else {
        var finder = Finder();
        if (id != null && id is Map) {
          finder.filter = convertFilters(id)!;
        }
        if (options['orderBy'] != null) {
          finder.sortOrders = convertSortOrder(options['orderBy']);
        }
        var result = await store!.findFirst(db!, finder: finder);
        if(result != null) {
          return cloneValue(result.value)
            ..addAll({
              'localKey': result.key
            });
        }
        return {};
      }
    }
  }

  setOptions(Map newOptions) {
    if (options is Map) {
      newOptions.forEach((key, value) {
        options[key] = value;
      });
    }
  }

  selectAll([filters]) async {
    await connect();
    if (store != null) {
      try {
        var finder = Finder();
        if (filters != null && filters is Map) {
          finder.filter = convertFilters(filters)!;
        }
        if (options['orderBy'] != '') {
          finder.sortOrders = convertSortOrder(options['orderBy']);
        }
        final result = await store!.find(db!, finder: finder);
        var _res = {};
        result.forEach((RecordSnapshot element) {
          _res.addAll({
            element.key: element.value
          });
        });
        return _res;
      } catch (e) {
      }
    }
  }

  insert(fields) async {
    await connect();
    if (store != null) {
      if (fields is Map) {
        if (fields.containsKey('_id')) {
          fields.remove('_id');
        }
        String id = fields.containsKey('id')?fields['id']:'${time()}';
        return await store!.record(id).put(db!, fields);
      }
      return await store!.add(db!, fields);
    }
  }
  inserts(dynamic items, [String key = 'id']) async {
    assert(items is Map || items is List, 'inserts: Kiểu dữ liệu không đúng định dạng');
    if(!empty(items)) {
      await connect();
      if (store != null) {
        Map _items = (items is Map)?items:Map<String, dynamic>.fromIterable(items, key: (v) => '${v[key]}', value: (v) => v);
        _items.updateAll((key, value) {
          return value..remove('_id');
        });
        return await store!.records(_items.keys).put(db!, _items.values.toList());
      }
    }
  }
  update(fields, id) async {
    await connect();
    if (store != null) {
      var record;
      if (id is int || id is String) {
        record = await store!.record(id).get(db!);
      } else {
        var result = await store!.findFirst(db!,
            finder: Finder(
              filter: convertFilters(id),
              sortOrders: convertSortOrder(options['orderBy']),
            ));
        record = result!.value;
      }
      if (fields != null && record != null) {
        final _res = await store!.record(id).update(db!, fields);
        return _res;
      }
    }
  }

  delete(filters) async {
    await connect();
    if (store != null) {
      if(filters is Map){
        return await store!.delete(db!,
            finder: Finder(filter: convertFilters(filters)));
      }else if(filters is int || filters is String){
        return await store!.delete(db!, finder: Finder(filter: Filter.byKey(filters)));
      }

    }
  }
  deleteAll([filters])async{
    await connect();
    final _items = await Data(store!.name).selectAll(filters);
    if(!empty(_items) && (store != null)){
      Future.forEach(_items.entries, (MapEntry  element)async{
        await delete(element.key);
      });
    }
  }
}
