import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:vhv_basic/import.dart';

enum SearchIcon { none, show, cancel }
enum SearchAction { ready, short, start, done, error, cancel }

class SearchController extends GetxController {
  SearchController([this.params]);
  final Map? params;

  final PublishSubject<String> _searchKeyword = new PublishSubject<String>();
  final StreamController<Search> _itemsController = new StreamController<
      Search>();
  final StreamController<SearchIcon> _showBtnController = new StreamController<
      SearchIcon>();
  final StreamController<bool> _inputSearchController = new StreamController<
      bool>();
  String _keyword = '',
      _oldKeyword = '';
  Map<String, String> _filters = new Map<String, String>();
  Search _items = new Search();
  bool _searching = false,
      _userCancel = false;

  PublishSubject get searchKeyWord => _searchKeyword;

  Stream<Search> get itemsStream => _itemsController.stream;

  Stream<SearchIcon> get showBtnSearch => _showBtnController.stream;

  Stream<bool> get inputSearchStream => _inputSearchController.stream;

  Search get items => _items;

  String get keyword => _keyword;

  Map<String, String> get filters => _filters;



  set keyword(String newVal) {
    if (newVal.length == 0) {
      _itemsController.add(new Search(
          searchAction: SearchAction.ready
      ));
      _showBtnController.add(SearchIcon.none);
    }
    if (newVal.length > 2) {
      _showBtnController.add(SearchIcon.show);
    } else {
      _showBtnController.add(SearchIcon.none);
    }
    _keyword = newVal;
  }

  set filters(Map<String, String> newVal) {
    newVal.forEach((key, value) {
      _filters.putIfAbsent(key, () => value);
    });
  }

  @override
  void onInit() {
    _searchKeyword.debounceTime(Duration(seconds: 2)).listen((keyword) {
      if (keyword.length > 2) {
        if (_searching == false) {
          _oldKeyword = keyword;
          _search(keyword);
        }
      } else if (keyword.length == 0) {
        _itemsController.add(new Search(
            searchAction: SearchAction.ready
        ));
      } else {
        _itemsController.add(new Search(
            searchAction: SearchAction.short
        ));
      }
    });
    if(params is Map){
      if(!empty(params!['keyword'])) {
        this.keyword = params!['keyword'];
        this.searchKeyWord.add(params!['keyword']);
        _itemsController.add(new Search(
            searchAction: SearchAction.start
        ));
      }
    }
    super.onInit();
  }

  void search([bool? cancel, bool? reSearch]) async {
    if ((cancel == null || cancel == false)) {
      _userCancel = false;
      if (_keyword.length > 2) {
        if (((reSearch != null && reSearch == true) ||
            (_keyword != _oldKeyword))) {
          _oldKeyword = _keyword;
          _search(_keyword, filters: _filters);
          _showBtnController.add(SearchIcon.cancel);
          _searching = true;
          _inputSearchController.add(true);
          await Future.delayed(Duration(seconds: 2));
          _searching = false;
        }
      } else if (_keyword.length == 0) {
        _itemsController.add(new Search(
            searchAction: SearchAction.ready
        ));
      } else {
        _itemsController.add(new Search(
            searchAction: SearchAction.short
        ));
      }
    } else {
      _showBtnController.add(SearchIcon.show);
      _inputSearchController.add(false);
      _itemsController.add(new Search(
          searchAction: SearchAction.cancel
      ));
      _userCancel = true;
    }
  }

  void _search(String keyword, {Map<String, dynamic>? filters}) async {
    // final int _itemPerPage = 20;
    // final int _pageNo = 1;
    // Map<String, dynamic> options = {};
    // int? _maxPage;
    // int totalItems = 0;

    _itemsController.add(Search(
        searchAction: SearchAction.start
    ));
    Map<String, String> _body = {
      'keyword': keyword,
      'itemsPerPage': '60',
      // 'orderBy': 'createdTime DESC',

    };
    if (filters != null && filters.length > 0) {
      _body.putIfAbsent('filters', () => json.encode(filters));
    }
    final _res = await call('Content.Portal.ClientSearch.search',
      params: _body,
    );
    if (_userCancel == false) {
      List<dynamic> _typeFilter = [],
          _categoriesFilter = [];
      List<Map<String, dynamic>> _lists = <Map<String, dynamic>>[];
      if (!empty(_res) && _res is Map) {
        final _type = _res['filterItems']['type'];
        if (_type['items'] != null) {
          _typeFilter = [];
          _type['items'].forEach((element) {
            _typeFilter.add({
              'code': element['code'] ?? '',
              'title': element['title'] ?? '',
              'translates': element['translates'] ?? [],
              'count': element['count'] ?? 0,
            });
          });
          final _categories = _res['filterItems']['categories'];
          if (_categories['items'] != null) {
            _categoriesFilter = [];
            _categories['items'].forEach((element) {
              _categoriesFilter.add({
                'id': element['id'],
                'title': element['title'] ?? '',
                'count': element['count'] ?? 0,
              });
            });
          }

          _items.filterItems = new Map<String, dynamic>();
          if (!empty(_categoriesFilter)) _items.filterItems!.putIfAbsent(
              'categories', () => _categoriesFilter);
          if (!empty(_typeFilter)) _items.filterItems!.putIfAbsent(
              'type', () => _typeFilter);

          final _types = _res['types'];
          _types.forEach((key, value) {
            if ((value['items'] != null && value['items'].length > 0)) {
              value['items'].forEach((k, v) {
                _lists.add(v);
              });
            }
          });
          _items.items = _lists;
          _items.searchAction = SearchAction.done;
          _items.totalItems = _lists.length;
          _itemsController.add(_items);
        } else {
          _itemsController.add(Search(
              searchAction: SearchAction.error
          ));
        }
        _showBtnController.add(SearchIcon.show);
      } else {
        _userCancel = false;
      }
      _inputSearchController.add(false);
    }
  }


  @override
  void dispose() {
    _inputSearchController.close();
    _showBtnController.close();
    _searchKeyword.close();
    _itemsController.close();
    super.dispose();
  }
}

class Search {
  SearchAction searchAction;
  Map<String, dynamic>? filterItems;
  List<Map<String, dynamic>>? items;
  int totalItems;

  Search({
    this.searchAction: SearchAction.ready,
    this.filterItems,
    this.items,
    this.totalItems = 0
  });
}