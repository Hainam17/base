import 'package:vhv_basic/import.dart';
import 'package:flutter/material.dart';
import 'Controller.dart';

class SearchPage extends StatelessPage {
  const SearchPage(this.params, {this.extraDetailBuilder});
  final Map? params;
  final Map<String, Widget Function(Map params)>? extraDetailBuilder;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchController>(
      init: SearchController(params),
      builder: (_controller){
        return Scaffold(
          appBar: factories['header'](
            context,
            hideSearchIcon: true,
            title: SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    StreamBuilder<bool>(
                      stream: _controller.inputSearchStream,
                      builder: (_, snapshot){
                        return _inputSearch((snapshot.hasData) ? snapshot.data:null);
                      },
                    ),
                    StreamBuilder<SearchIcon>(
                        stream: _controller.showBtnSearch,
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            switch (snapshot.data) {
                              case SearchIcon.show:
                                return IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _controller.search(false,true);
                                    });
                              case SearchIcon.cancel:
                                return IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _controller.search(true);
                                    });
                              default:
                                return const SizedBox();
                            }
                          } else {
                            return const SizedBox();
                          }
                        }
                    )
                  ],
                )
            ),
          ),
          body: Container(
            child: StreamBuilder<Search>(
                stream: _controller.itemsStream,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final _result = snapshot.data;
                    switch (_result!.searchAction) {
                      case SearchAction.start:
                        return Container(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      case SearchAction.done:
                        if (_result.items!.length > 0) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: ListView.separated(
                              separatorBuilder: (_, index) => const Divider(
                                color: Colors.transparent,
                                height: 10,
                              ),
                              itemCount: _result.items!.length,
                              itemBuilder: (_, index) {
                                final Map item = _result.items![index];
                                if(extraDetailBuilder != null){
                                  String? _key;
                                  for(var a in extraDetailBuilder!.keys){
                                    if(item['type'].startsWith(a)){
                                      _key = a;
                                    }
                                    if(a == item['type']){
                                      return extraDetailBuilder![a]!(item);
                                    }
                                  }
                                  if(_key != null){
                                    return extraDetailBuilder![_key]!(item);
                                  }
                                }
                                return ListTile(
                                  title: Text(item['title']??''),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                                'Không tìm thấy kết quả phù hợp với từ khóa: %s'.lang(args: [_controller.keyword])),
                          );
                        }
                      case SearchAction.error:
                        return Center(
                          child: Text('Có lỗi xảy ra'.lang()),
                        );
                      case SearchAction.short:
                        return Center(
                          child: Text('Vui lòng nhập từ %s ký tự trở lên để tìm kiếm'.lang(args: ['3'])),
                        );
                      case SearchAction.cancel:
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Bạn đã hủy tìm kiếm'.lang()),
                              const SizedBox(height: 10,),
                              IconButton(icon: const Icon(Icons.refresh, size: 30,), onPressed: (){
                                _controller.search();
                              })
                            ],
                          ),
                        );
                      default:
                        return Center(
                          child: Text('Nhập từ khóa để tìm kiếm'.lang()),
                        );
                    }
                  } else {
                    return Center(
                      child: Text('Nhập từ khóa để tìm kiếm'.lang()),
                    );
                  }
                }
            ),
          ),
        );
      },
    );
  }

  Widget _inputSearch([bool? disable]) {
    final _controller =Get.find<SearchController>();
    return TextFormField(

      initialValue: _controller.keyword,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 15, right: 40),
        hintText: 'Tìm kiếm'.lang(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
      ),
      autofocus: !empty(params!['keyword'])?false:true,
      enabled: (disable != null && disable == true) ? false : true,
      onChanged: (val) {
        _controller.keyword = val;
        _controller.searchKeyWord.add(val);
      },
      onFieldSubmitted: (val) {
        _controller.search();
      },
    );
  }
}
