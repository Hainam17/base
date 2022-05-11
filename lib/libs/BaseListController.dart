import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:rxdart/rxdart.dart';
class BaseListController extends ChangeNotifier {
  final String? service;
  final Duration? cacheTime;
  final Map<String, dynamic>? extraParams;
  final bool hasNow;
  final bool? forceRefresh;


  BaseListController(this.service,
      {this.cacheTime = const Duration(minutes: 1), this.forceRefresh,
        this.extraParams, this.hasNow = false}) {
    _selectAll();

  }
  bool paging = false;
  PublishSubject<String>? _searchKeyword;
  PublishSubject? get searchKeyWord => _searchKeyword;
  List<String>? _itemKeys;
  List<dynamic>? items;
  bool _mounted = true;
  bool get mounted => _mounted;
  int totalItems = 0;
  int? _maxPage;
  int? get maxPage => _maxPage;
  String? keyword;
  bool _isLoading = false;
  bool _searching = false;
  bool hasMax = false;
  late Map<String, dynamic> _extraParams = <String, dynamic>{};

  late Map<String, dynamic> filters = <String, dynamic>{};
  late Map<String, dynamic> options = {'pageNo': 1, 'itemsPerPage': 20};

  refresh()async{
    await _selectAll(false, null);
  }
  
  setParams(Map<String, dynamic> _params){
    _extraParams..addAll(_params);
  }
  _selectAll([bool isPaging = false,Map<String, dynamic>? searchParams]) async {
    if(!empty(filters)){
      filters.removeWhere((key, value) => empty(value));
    }
    final int _itemPerPage = _extraParams['itemsPerPage']??(options['itemsPerPage']??20);
    final int _pageNo = _extraParams['pageNo']??(options['pageNo']??1);
    _isLoading = true;
    if (!paging) {
      Map<String, dynamic> _params = {};
      if (!empty(filters)) {
        _params..addAll({'filters': filters});
      }
      if (!empty(options)) {
        _params..addAll({'options': options});
      }
      if (!empty(extraParams)) {
        _params..addAll(extraParams!);
      }
      if (!empty(_extraParams)) {
        _params..addAll(_extraParams);
      }
      if (!empty(searchParams)) {
        _params..addAll(searchParams!);
      }
      final _res =
          await call(this.service!, params: _params, cacheTime: cacheTime, forceRefresh: forceRefresh);
      if (isPaging) {
        paging = true;
      }else{
        items = null;
      }
      if (_res != null){
        if(_res is Map && _res['items'] != null) {
          if(!empty(_res['items'])) {
            if (!empty(_res['totalItems'])) {
              totalItems = _res['totalItems'];
              _maxPage = (totalItems / options['itemsPerPage']).ceil();
              if (totalItems < options['itemsPerPage']) {}
            }
            if (!isPaging) {
              items = (_res['items'] is Map)
                  ? _res['items'].values.toList()
                  : _res['items'];
            } else {
              items = items!
                ..addAll((_res['items'] is Map)
                    ? _res['items'].values.toList()
                    : _res['items']);
            }
            if(_res['items'].length < _itemPerPage??20){
              _maxPage = _pageNo;
              hasMax = true;
            }
          }else{
            hasMax = true;
          }
        }else if(_res is List){
          if(_res.length > 0) {
            if(_res.length < options['itemsPerPage']){
              _maxPage = _pageNo;
              hasMax = true;
            }
            items = (isPaging?items:[])!..addAll(_res);
          }else{
            _maxPage = _pageNo;
            hasMax = true;
          }
        }
      } else {
        if (!isPaging) items = [];
      }
      if(empty(items)){
        items = [];
      }
      _itemKeys = items!.map<String>((e){
        return e['id'];
      }).toList();
      await prepareList(!empty(_res)?_res:{});
    }
  }

  @protected
  prepareList(_res) async {
    if(_mounted) {
      update();
      if(paging) {
        if(hasNow){
          paging = false;
          update();
        }else{
          Future.delayed(const Duration(seconds: 2), () {
            paging = false;
            update();
          });
        }
      }
    }
    _isLoading = false;
  }

  nextPage(int pageNo) async {
    if(!_isLoading && !_searching) {
      if (!paging && ((_maxPage != null && _maxPage! >= pageNo) || !hasMax)) {
        options['pageNo'] = pageNo;
        await _selectAll(true);
      }
    }
  }
  search() async {
    await _selectAll();
  }

  searchByKeyword([String? name, String? value, bool now = false]) async {
    _searching = true;
    options['pageNo'] = 1;
    if(value != null){
      if(!now) {
        if (_searchKeyword == null) {
          _searchKeyword = new PublishSubject<String>();
          _searchKeyword!.debounceTime(const Duration(seconds: 2)).listen((keyword) async{
            await _selectAll(false, {
              '${name ?? 'keyword'}': keyword
            });
            _searching = false;
          });
        } else {
          _searchKeyword!.add(value);
        }
      }else{
        await _selectAll(false, {
          '${name ?? 'keyword'}': value
        });
        _searching = false;
      }
    }
  }
  @protected
  deleteSuccess(String id){
    if(_itemKeys!.contains(id)){
      final int _index = _itemKeys!.indexOf(id);
      items!.removeAt(_index);
      update();
    }
  }

  callSelectAll(Map<String, dynamic>? filter) async {
    await _selectAll(false, filter);
  }

  cancelSearch() async {
    filters = {};
    await _selectAll();
  }
  update(){
    if(_mounted)notifyListeners();
  }

   back(){
    if(_mounted)appNavigator.pop();
  }

  @override
  dispose() {
    _searchKeyword?.close();
    _mounted = false;
    super.dispose();
    
  }
}
