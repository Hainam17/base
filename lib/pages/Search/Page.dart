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
                                'Kh??ng t??m th???y k???t qu??? ph?? h???p v???i t??? kh??a: %s'.lang(args: [_controller.keyword])),
                          );
                        }
                      case SearchAction.error:
                        return Center(
                          child: Text('C?? l???i x???y ra'.lang()),
                        );
                      case SearchAction.short:
                        return Center(
                          child: Text('Vui l??ng nh???p t??? %s k?? t??? tr??? l??n ????? t??m ki???m'.lang(args: ['3'])),
                        );
                      case SearchAction.cancel:
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('B???n ???? h???y t??m ki???m'.lang()),
                              const SizedBox(height: 10,),
                              IconButton(icon: const Icon(Icons.refresh, size: 30,), onPressed: (){
                                _controller.search();
                              })
                            ],
                          ),
                        );
                      default:
                        return Center(
                          child: Text('Nh???p t??? kh??a ????? t??m ki???m'.lang()),
                        );
                    }
                  } else {
                    return Center(
                      child: Text('Nh???p t??? kh??a ????? t??m ki???m'.lang()),
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
        hintText: 'T??m ki???m'.lang(),
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
