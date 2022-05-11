import 'package:vhv_basic/import.dart';
import 'package:vhv_basic/libs/DataLib.dart';

class BaseModel {
  final String modelName;
  final String tableName;
  final Duration? cacheTime;
  final String? submitService;
  late bool usingDB;
  final bool? forceRefresh;
  BaseModel(
    this.tableName,
    this.modelName,{
      this.submitService,
      this.cacheTime,
      this.forceRefresh: true,
    this.usingDB: false,
  });

  int totalItems = 0, pageNo = 1, itemsPerPage = 20, _maxPage = 0;
  Map<String, dynamic>? _params;
  Map<String, dynamic>? _options;
  bool _paging = false;

  Future<Map<String, dynamic>?> select(id) async {
    final callItem = await call(modelName + '.select',
        params: {'id': id}, cacheTime: cacheTime);
    if (callItem != null) {
      final dataItem = await Data(tableName).select(id);
      if (dataItem == null) {
        if (usingDB) Data(tableName).insert(dataItem);
      } else {
        if (usingDB) Data(tableName).update(dataItem, id);
      }
      return (callItem is Map<String, dynamic>)?callItem:<String, dynamic>{};
    }
    if (usingDB) {
      final dataItem = await Data(tableName).select(id);
      if (dataItem != null) {
        return dataItem;
      }
    }
    return null;
  }

  Future<Map?> selectAll([Map<String, dynamic>? params]) async {
    _params = params ?? {};
    if (_options == null) {
      _options = params?.putIfAbsent(
          'options',
              () =>
          <String, dynamic>{
            'itemsPerPage': itemsPerPage,
            'pageNo': pageNo,
            'orderBy': 'createdTime DESC'
          }) ??
          <String, dynamic>{
            'itemsPerPage': itemsPerPage,
            'pageNo': pageNo,
            'orderBy': 'createdTime DESC'
          };
    }else{
      if(!empty(_params!['options'])){
        _options!['pageNo'] = _params!['options']['pageNo']??pageNo;
        _options!['itemsPerPage'] = _params!['options']['itemsPerPage']??itemsPerPage;
      }

    }
    final callList = await call(modelName + '.selectAll',
        params: _params, cacheTime: cacheTime, forceRefresh: forceRefresh!);
    if (callList is Map && callList.containsKey('items')) {
      if (callList['items'] is List) {
        Map<String, dynamic> newMap = {};
        callList['items'].forEach((element) {
          if (element is Map && element.containsKey('id')) {
            newMap[element['id']] = element;
          }
        });
        callList['items'] = newMap;
      }
      if (callList['items'] is Map) {
        callList['items'].forEach((key, element) async {
          if (element is Map && element.containsKey('id')) {
            if (element.containsKey('_id')) {
              element.remove('_id');
            }
            if (usingDB) {
              final dataItem = await Data(tableName).select(element['id']);
              if (dataItem == null) {
                Data(tableName).insert(element);
              } else {
                Data(tableName).update(element, element['id']);
              }
            }
          }
        });
      }
      totalItems = callList['totalItems'] ?? callList['items'].length;
      _options = callList['options'] ?? {};
      pageNo =
          _options!.putIfAbsent('pageNo', () => pageNo).toString().parseInt();
      itemsPerPage = _options!
          .putIfAbsent('itemsPerPage', () => itemsPerPage)
          .toString()
          .parseInt();
      _maxPage = (totalItems / itemsPerPage).ceil();
      _paging = false;
      return callList;
    }
    if (usingDB) {
      final Map<String, dynamic>? dataList = await selectFromLocal(params);
      if (dataList != null) {
        return {'items': dataList, 'totalItems': dataList.length, 'readOnly': true};
      }
    }
    return {'items': {}, 'totalItems': 0};
  }

  selectFromLocal(params) async {
    final db = Data(tableName);
    if (params['options'] != null) {
      db.setOptions(params['options']);
    }
    return await db.selectAll(params['filters'] ?? {});
  }

  insert(fields) async {
    final callInsert =
        await call(submitService??(modelName + '.edit'), params: {'fields': fields, 'colomboDebug2':'1'});
    if (usingDB && callInsert != null) {
      if (callInsert.containsKey('id')) {
        fields['id'] = callInsert['id'];
        Data(tableName).insert(fields);
      }
    }
    return callInsert;
  }

  update(fields, id) async {
    final callUpdate =
        await call(modelName + '.edit', params: {'fields': fields, 'id': id});
    if (usingDB && callUpdate != null) {
      Data(tableName).update(fields, id);
      return callUpdate;
    }
    return callUpdate;
  }

  delete(filters) async {
    final callDelete =
        await call(modelName + '.delete', params: {'id': filters});
    if (usingDB && callDelete != null) {
      Data(tableName).delete(filters);
      return callDelete;
    }
  }

  nextPage([Map<String, dynamic>? options]) async {
    if (!_paging) {
      _paging = true;
      if (pageNo < _maxPage) {
        Map<String, dynamic>? _option = options ?? _options;
        _option!['pageNo'] = ++pageNo;
        _params!['options'] = _option;
        return await selectAll(_params);
      }
    }
    return null;
  }

  checkLoadMore() {
    if (_maxPage > pageNo) {
      return true;
    }
    return false;
  }
}
