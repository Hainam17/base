import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';
import 'package:rxdart/rxdart.dart';

class GetBaseListController extends GetxController {
  String service;
  final Duration? cacheTime;
  final Map<String, dynamic>? extraParams;
  late bool hasNow = false;
  final bool? forceRefresh;
  late bool initNow = true;
  final String? identification;
  final String? groupId;
  final bool notCheckLength;
  final Map<String, dynamic>? initFilters;
  GetBaseListController(this.service,
      {this.groupId, this.identification, this.initNow = true,
        this.cacheTime = const Duration(seconds: 30), this.forceRefresh,
        this.extraParams, this.notCheckLength = false, this.hasNow = false, this.initFilters});
  bool paging = false;
  PublishSubject<String>? searchKeyword;
  List<dynamic>? itemKeys;
  List? items;
  List? _itemsTemp;
  bool mounted = true;
  int totalItems = 0;
  int? maxPage;
  String? keyword;
  bool _isLoading = false;
  bool _searching = false;
  bool hasMax = false;
  int lastClearCache = 0;
  Map<String, dynamic> _extraParams = <String, dynamic>{};
  String selectAllTime = '${time()}';
  Map<String, dynamic> filters = <String, dynamic>{};
  Map<String, dynamic> _hardFilters = <String, dynamic>{};
  Map<String, dynamic> options = {'pageNo': 1, 'itemsPerPage': 20};
  List<String> selectedIds = [], _idsProcessing = [];
  int? indexMax;
  bool hasPaddingBottom = false;
  bool Function(Map item)? conditionChecked;
  bool processing = false;
  RxInt countSelectedIds = 0.obs;
  VoidCallback? beforeClose;
  int? minLevel;
  PublishSubject<int>? check;
  ValueNotifier<Map<String, dynamic>> tempFilters = ValueNotifier<Map<String, dynamic>>({});
  Map expansionVariable = <String, dynamic>{};

  @override
  onInit(){
    // if(!empty(counterShimmer)){
    //   items = List.generate(20, (index) => {});
    //   update();
    // }
    if(initFilters != null){
      filters.addAll(initFilters!);
      _hardFilters.addAll(initFilters!);
    }else{
      _hardFilters.addAll(filters);
    }
    setOptions(options);
    tempFilters.value = <String, dynamic>{}..addAll(filters);
    if(empty(service))hasMax = true;
    if(initNow){
      _init();
    }
    super.onInit();
  }

  setFilterTemp(String key, dynamic value){
    tempFilters.value = <String, dynamic>{
    }..addAll(tempFilters.value)..addAll({key: value});
  }

  applyFilter()async{
    filters.addAll(tempFilters.value);
    showLoading();
    await selectAll();
    disableLoading();
  }

  _init()async{
    await _selectAll();
  }
  getItemsKey(){
    if(!empty(_itemsTemp??items)) {
      itemKeys = (_itemsTemp??items)!.map<String>((e){
        final int? _level = parseInt(e['level']??1);
        minLevel = (minLevel == null)?_level??1:min(minLevel!, _level??1);
        return (e['id'] ?? e['code']).toString();
      }).toList();
    }else{
      itemKeys = [];
    }
    return itemKeys;
  }

  bool? isSelected(String id, [bool hasNull = false, Map? item]){
    if(conditionChecked == null || conditionChecked!(item!)) {
      if (!hasNull) return selectedIds.contains(id);
      if (!empty(selectedIds)) return selectedIds.contains(id);
    }
    return null;
  }
  removeSelectedIds(){
    selectedIds = [];
    countSelectedIds.value = 0;
    update();
  }
  void checkAllIds() {
    selectedIds = [];
    (_itemsTemp??items)!.forEach((e) {
      if (conditionChecked == null || conditionChecked!(e)) {
        selectedIds.add(e['id']);
      }
    });
    update();
  }
  onSelected(String id, [bool hasUpdate = true]){
    final Map _item = getItemById(id);
    if(conditionChecked == null || conditionChecked!(_item)) {
      if (!processing) {
        if (selectedIds.contains(id)) {
          selectedIds.remove(id);
        } else {
          selectedIds.add(id);
        }
        countSelectedIds.value = selectedIds.length;
        if (hasUpdate) update();
      }
    }
  }

  selectAll({Map<String, dynamic>? params, bool clearCache = false})async{
    if(mounted) {
      if(clearCache){
        if(lastClearCache + 10 > time()){
          clearCache = false;
        }else{
          lastClearCache = time();
        }
      }
      await _selectAll(
        isPaging: false,
        callParams: params,
        force: clearCache,
      );
    }
  }

  setParams(Map<String, dynamic>? _params){
    _extraParams..addAll(_params??{});
  }
  setOptions(Map<String, dynamic> _params){
    options..addAll(_params);
  }
  dynamic
  _checkNull(Map<String, dynamic>? _params){
    _params!.removeWhere((key, value){
      if(!empty(value, true)){
        if(value is Map<String, dynamic>){
          _params[key] = _checkNull(value);
        }
        return false;
      }else{
        return true;
      }
    });
    return _params;
  }

  _selectAll({bool isPaging = false, Map <String, dynamic>? callParams, bool force = false, bool clearCache = false}) async {
    if(expansionVariable.containsKey('valueIsScrollDown')
        && (expansionVariable['valueIsScrollDown'] is ValueNotifier) && !isPaging){
      expansionVariable['valueIsScrollDown'].value = false;
      await Future.delayed(Duration(milliseconds: 500));
    }
    if(!isPaging){
      countSelectedIds.value = 0;
      options['pageNo'] = 1;
      selectedIds = [];
    }
    if(!empty(service)) {
      final int _itemPerPage = _extraParams['itemsPerPage'] ??
          (options['itemsPerPage'] ?? 20);
      final int _pageNo = _extraParams['pageNo'] ?? (options['pageNo'] ?? 1);
      _isLoading = true;
      if (!paging) {
        Map<String, dynamic> _params = {};
        if (!empty(filters)) {
          filters.forEach((key, value) {
            if(value is String){
              filters[key] = value.trim();
            }
          });
          _params..addAll({'filters': filters});
        }
        if (!empty(options)) {

          _params..addAll({'options': options});
        }
        if (!empty(extraParams)) {
          if(extraParams!.containsKey('options')){
            if(_params.containsKey('options')){
              _params['options']?.addAll(extraParams!['options']);
            }else{
              _params['options'] = extraParams!['options'];
            }
          }
          if(extraParams!.containsKey('filters')){
            if(_params.containsKey('filters')){
              _params['filters']?.addAll(extraParams!['filters']);
            }else{
              _params['filters'] = extraParams!['filters'];
            }
          }
          _params..addAll({}..addAll(extraParams!)..remove('options')..remove('filters'));
        }
        if (!empty(_extraParams)) {

          _params..addAll(_extraParams);
        }
        if (!empty(callParams)) {
          _params..addAll(callParams!);
        }
        if(clearCache){
          _params.addAll({
            'colomboDebug2': '1'
          });
        }
        final _res =
        await call(this.service, params: !empty(options['noCheckNull'])
            ?_params:_checkNull(_params)..addAll({
          if(!empty(groupId))'groupId': groupId??factories['groupId']
        }),
            cacheTime: cacheTime,
            isRetry: true,
            forceRefresh: (force == true)?force:(cacheTime != null
                ?((forceRefresh != null)?forceRefresh!:false):true));
        if (isPaging) {
          paging = true;
        } else {
          items = [];
        }
        if (_res != null) {
          if (_res is Map && _res[identification??'items'] != null) {
            if (!empty(_res[identification??'items'])) {
              if (!empty(_res['totalItems'])) {
                totalItems = parseInt(_res['totalItems'].toString());
                options['itemsPerPage'] = options['itemsPerPage']??_res['itemsPerPage'];
                options['pageNo'] = options['pageNo']??_res['pageNo'];
                maxPage = (totalItems / options['itemsPerPage']).ceil();
                if (totalItems < options['itemsPerPage']) {}
              }else{
                maxPage = null;
              }
              if (!isPaging) {
                items = (_res[identification??'items'] is Map)
                    ? _mapToList(_res[identification??'items'])
                    : _res[identification??'items'];
              } else {
                items = items!
                  ..addAll((_res[identification??'items'] is Map)
                      ? _mapToList(_res[identification??'items'])
                      : _res[identification??'items']);
              }
              if (!notCheckLength && (_res[identification??'items'].length < _itemPerPage ?? 20)) {
                maxPage = (maxPage != null)?_pageNo:null;
                hasMax = true;
              }
            } else {
              hasMax = true;
            }
          } else if (_res is List) {
            if (_res.length > 0) {
              if (_res.length < options['itemsPerPage']) {
                maxPage = (maxPage != null)?_pageNo:null;
                hasMax = true;
              }else{
                hasMax = false;
              }
              items = (isPaging ? items : [])!
                ..addAll(_res);
            } else {
              maxPage = (maxPage != null)?_pageNo:null;
              hasMax = true;
            }
          }else{
            if (!isPaging) items = [];
          }
        } else {
          if (!isPaging) items = [];
        }
        if (empty(items)) {
          items = [];
        }
        await prepareList(!empty(_res) ? _res : {});

      }
    }else{
      await prepareList({});
    }
  }
  List _mapToList(Map<String, dynamic> items){
    return items.entries.map((entry){
      if(empty(entry.value['id'])){
        return <String, dynamic>{
          'id': '${entry.key}',
        }..addAll(entry.value);
      }
      return entry.value;
    }).toList();
  }
  getIndex(String id){
    return itemKeys?.indexOf(id);
  }
  getItemById(dynamic id){
    if(id is String || id is num) {
      final int? index = getIndex(id.toString());
      if (index != null && index >= 0) {
        final _item = (_itemsTemp ?? items)!.elementAt(index);
        return _item;
      }
    }
  }

  getTitleById(var id, [bool short = false]){
    if(id is String || id is num){
      final int? index = getIndex(id.toString());
      if(index != null && index >= 0){
        final _item = (_itemsTemp??items)!.elementAt(index);
        return (_item['title']??(_item['label']??_item['fullName']))??'';
      }
    }else if(id is List){
      List<String> _titles = [];
      id.removeWhere((_id) => empty(_id, true));
      if(short && id.length > 2){
        return '${id.length} ${'lựa chọn'.lang()}';
      }
      id.forEach((element) {
        if(!empty(element, true))_titles.add(getTitleById(element.toString()));
      });
      return !empty(_titles, true)?(_titles.join(', ')):'';
    }

  }
  @protected
  prepareList(_res) async {
    if(!empty(keyword) && !empty(_itemsTemp)){
      final Map<String, dynamic> _res2 = await _searchLocal(<String, dynamic>{
        'items': items,
        'minLevel': minLevel,
        'itemsTemp': _itemsTemp,
        'keyword': keyword
      });
      items = _res2['items'];
      _itemsTemp = _res2['itemsTemp'];
      minLevel = _res2['minLevel'];
    }
    getItemsKey();
    if(mounted) {
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
      if (!paging && ((maxPage != null && maxPage! >= pageNo) || !hasMax)) {
        options['pageNo'] = pageNo;
        await _selectAll(isPaging: true);
      }
    }
  }
  search({bool refresh = false}) async {
    if(!empty(filters)){
      filters.removeWhere((key, item) => empty(item, true));
    }
    if(refresh) {
      options['pageNo'] = 1;
    }
    await _selectAll();
  }

  searchByKeyword([String name = 'keyword', String? value, bool now = false]) async {
    _searching = true;
    options['pageNo'] = 1;
    String? _name;
    if(isset(value)){
      keyword = value;
    }
    if(name.startsWith('filters[')){
      _name = '${(name.substring(8, name.lastIndexOf(']')))}';
      if(isset(value)){
        keyword = value;
      }
      filters[_name] = keyword;
    }
    if(value != null){
      if(!now) {
        if (searchKeyword == null) {
          searchKeyword = new PublishSubject<String>();
          searchKeyword!.debounceTime(const Duration(seconds: 1)).listen((keyword) async{
            if(!empty(_name)){

            }
            await _selectAll(callParams: empty(_name)?{
              '$name': keyword
            }:null);
            _searching = false;
          });
        } else {
          searchKeyword!.add(value);
        }
      }else{
        if(value ==''){
          if(!empty(_name))filters.remove(_name);
          await _selectAll();
        }
        else{
          await _selectAll(callParams: empty(_name)?{
            '$name': value
          }:null);
        }

        _searching = false;
      }
    }
  }
  delete(String id, {
    String? title,
    String? middleText,
  })async{
    appNavigator.showDialog(
        title: title??'Xác nhận'.lang(),
        textConfirm: 'Đồng ý'.lang(),
        textCancel: 'Hủy bỏ'.lang(),
        middleText: middleText??'Bạn có chắc chắn muốn xóa?'.lang(),
        confirmTextColor: Colors.white,
        onCancel:(){},
        onConfirm: ()async{
          appNavigator.pop();
          final _res = await call(changeTail(service,'delete'), params: {
            'id': id,
            if(!empty(groupId))'groupId': groupId??factories['groupId']
          });
          if(!empty(_res) && _res is Map && _res['status'] == 'SUCCESS'){
            showMessage('${!empty(_res['message'])?_res['message']:'Thành công'}', type: 'SUCCESS');
            deleteSuccess(id);
          }
          else if(!empty(_res) && _res is Map && _res['status'] == 'FAIL' && !empty(_res['message'])){
            showMessage('${!empty(_res['message'])?_res['message']:''}', type: 'ERROR');
          }
          else{
            showMessage('Có lỗi xảy ra', type: 'ERROR');
          }
        }
    );
  }
  deleteSuccess(String id){
    if(itemKeys!.contains(id)){
      final int _index = itemKeys!.indexOf(id);
      (_itemsTemp??items)!.removeAt(_index);
      itemKeys!.remove(id);
      update();
    }
  }
  updateById(String id, Map<String, dynamic> params){
    if(itemKeys!.contains(id)){
      final int _index = itemKeys!.indexOf(id);
      items![_index] = items!.elementAt(_index)..addAll(params);
      update();
    }
  }
  insertFirst(dynamic item){
    List _temp = [item];
    _temp.addAll(items!);
    items = _temp;
    itemKeys = (_itemsTemp??items)!.map<String>((e){
      return e['id']??e['code'];
    }).toList();
    update();
  }

  callSelectAll(dynamic filter) async {
    await _selectAll(callParams: filter);
  }

  resetFilter() async {
    tempFilters.value = {}..addAll(_hardFilters);
    if(!mapEquals(_hardFilters, filters)){
      filters = <String, dynamic>{}..addAll(_hardFilters);
      await _selectAll();
    }
  }

  back(){
    if(mounted)appNavigator.pop();
  }

  changeStatus(String id, String status, String title,{String? middleText,Color? confirmTextColor, Map<String, dynamic>? params })async{
    appNavigator.showDialog(
        title: title,
        middleText: middleText ?? 'Bạn có chắc?',
        textConfirm: 'Đồng ý',
        textCancel: 'Hủy',
        confirmTextColor: confirmTextColor,
        onCancel: (){
        },
        onConfirm: ()async{
          appNavigator.pop();
          final _res = await call(changeTail(service,'changeStatus'),params: !empty(params) ? params : {
            'status': status,
            'id': id,
            if(!empty(groupId))'groupId': groupId??factories['groupId']
          });
          if(_res != null && _res is Map){
            if(_res['status'] == 'SUCCESS'){
              final int index = getIndex(id);
              items![index]['status'] = status;
              update();
            }
            showMessage(_res['message']??((_res['status'] == 'SUCCESS')?'Thành công':'Thất bại'), type: _res['status']);
          }
        }
    );
  }



  action(String service, {
    ///Tham số truyền theo nếu có
    Map<String, dynamic>? params,
    String? title,
    String? middleText,
    ///Xóa khi thực hiện thành công 1 bản ghi
    final bool? removeOnSuccess,
  })async{
    appNavigator.showDialog(
        title: title??'Xác nhận!',
        middleText: middleText??'Bạn có chắc?',
        textConfirm: 'Đồng ý',
        textCancel: 'Hủy',
        confirmTextColor: Colors.white,
        onCancel: (){

        },
        onConfirm: ()async{
          appNavigator.pop();
          params = params??<String, dynamic>{};
          final _res = await call(service,params: params!..addAll({
            if(!empty(groupId))'groupId': groupId??factories['groupId']
          }));
          if(_res is Map){
            if(_res['status'] == 'SUCCESS'){
              if(!empty(removeOnSuccess) && !empty(params!['id'])){
                deleteSuccess(params!['id']);
              }
              if(!empty(_res['message']))showMessage(_res['message']??'Thao tác thành công!', type: 'success');
              if(empty(removeOnSuccess)){
                selectAll();
              }else{
                update();
              }
            }else{
              if(!empty(_res['message']))showMessage(_res['message']??'Thao tác thất bại!', type: 'error');
            }
          }
        }
    );
  }

  multiAction(String service, {
    ///Tham số truyền theo nếu có
    Map<String, dynamic>? params,
    String? title,
    String? middleText,
    ///Xóa khi thực hiện thành công 1 bản ghi
    final bool? removeOnSuccess,
  })async{
    appNavigator.showDialog(
        title: title??'Xác nhận!',
        middleText: middleText??'Bạn có chắc?',
        textConfirm: 'Đồng ý',
        textCancel: 'Hủy',
        confirmTextColor: Colors.white,
        onCancel: (){

        },
        onConfirm: ()async{
          appNavigator.pop();
          processing = true;
          _idsProcessing.addAll(selectedIds);
          selectedIds = [];
          update();
          //await Future.delayed(Duration(seconds: 10));
          params = params??<String, dynamic>{};
          int _fail = 0;
          await Future.forEach(_idsProcessing, (String id)async{
            params!.addAll({
              'id': id
            });
            final _res = await call(service,params: params!..addAll({
              if(!empty(factories['groupId']))'groupId': factories['groupId']
            }));
            if(_res is Map){
              if(_res['status'] == 'SUCCESS'){
                if(!empty(removeOnSuccess)){
                  deleteSuccess(id);
                }
              }else{
                _fail++;
              }
            }
          });
          if(_fail == _idsProcessing.length){
            showMessage('Thao tác thất bại!', type: 'error');
          }else if(_fail > 0){
            showMessage('${_idsProcessing.length - _fail} thành công. $_fail thất bại!', type: 'warning');
          }else{
            showMessage('Thao tác thành công!', type: 'success');
          }
          _idsProcessing = [];
          processing = false;
          if(empty(removeOnSuccess)){
            selectAll();
          }else{
            update();
          }
        }
    );
  }

  checkOnProcessing(String id){
    return (processing && _idsProcessing.contains(id));
  }

  setFirstIndex(int index){
    if(check == null) {
      check = new PublishSubject<int>();
      check!.debounceTime(const Duration(seconds: 1)).listen((keyword) async {

        if(indexMax == null){
          indexMax = keyword;
          check!.close();
          update();
        }

      });
    }
    if(!check!.isClosed)check!.add(index);
  }


  searchLocal(String _keyword)async{
    keyword = _keyword;
    final Map<String, dynamic> _res = await _searchLocal(<String, dynamic>{
      'items': items,
      'minLevel': minLevel,
      'itemsTemp': _itemsTemp,
      'keyword': keyword
    });
    items = _res['items'];
    _itemsTemp = _res['itemsTemp'];
    minLevel = _res['minLevel'];
    update();
    // _searchLocal();
  }

  Future<Map<String, dynamic>> _searchLocal(Map<String, dynamic> data)async{
    int? minLevel = data['minLevel'];
    if(minLevel == null)minLevel = 0;
    if(data['itemsTemp'] == null)data['itemsTemp'] = []..addAll(data['items']);
    data['items'] = []..addAll(data['itemsTemp']);
    data['items'].removeWhere((element){
      final bool _remove = ((convertUtf8ToLatin(element['title']??element['label']).toString().toLowerCase()).indexOf(convertUtf8ToLatin(data['keyword'].toLowerCase().trim())) == -1);
      if(!_remove){
        int? level = element['level'];
        if(level == null)level = 0;
        if(minLevel == null) minLevel = level;
        minLevel = min(minLevel??0, level);
      }
      return _remove;
    });
    return data..addAll(<String, dynamic>{
      'minLevel': minLevel
    });
  }

  changeField(String id, Map<String, dynamic> params){
    final int index = getIndex(id);
    Map item = items!.elementAt(index);
    item.addAll(params);
    update();
  }

  ///gán filter fix cứng, k bị xóa bởi hàm cancelSearch
  handFilter(String key, dynamic value){
    _hardFilters.addAll(<String, dynamic>{
      key: value
    });
    filters.addAll(<String, dynamic>{
      key: value
    });
  }

  @override
  onClose() {
    check?.close();
    if(beforeClose != null){
      beforeClose!();
    }
    expansionVariable.forEach((key, value) {
      if(value is ValueNotifier){
        value.dispose();
      }
      if(value is ScrollController){
        value.dispose();
      }
    });
    searchKeyword?.close();
    mounted = false;
    super.onClose();
  }
}
