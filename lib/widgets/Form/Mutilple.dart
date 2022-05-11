import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class FormMultiple extends StatefulWidget {
  final ValueChanged? onChanged;
  final String? titleAddNew;
  final bool hideAddNew;
  final bool hideDelete;
  final Color? colorAdd;
  final dynamic values;
  final Function? onReload;
  final Widget Function(dynamic item, Function(dynamic val) onChanged,int index)
  builder;
  const FormMultiple(
      {Key? key,
        required this.builder,
        this.onChanged,
        this.values,
        this.titleAddNew = 'Thêm',
        this.colorAdd,
        this.hideAddNew: false,
        this.hideDelete: false,
        this.onReload})
      : super(key: key);
  @override
  _FormMultipleState createState() =>
      _FormMultipleState();
}

class _FormMultipleState extends State<FormMultiple> {
  Map<dynamic, dynamic> _items = {};
  int _count = 0;
  @override
  void initState() {
    if (!empty(widget.values)) {
      convertToItems(widget.values);
    }
    super.initState();
  }


  @override
  void didChangeDependencies() {
    convertToItems(widget.values);
    if(!empty(widget.values)){
      if(widget.onChanged != null)widget.onChanged!(_items);
    }
    super.didChangeDependencies();
  }

  convertToItems(dynamic value){
    if(value is List){
      _items = {};
      int index = 1;
      value.forEach((element) {
        _items.addAll({
          '$index': element..addAll({
            'sortOder': index
          })
        });
        index++;
      });
    }else{
      _items = (value is Map && value.length > 0) ? value : <dynamic, dynamic>{'1': {}};
    }

  }

  @override
  void didUpdateWidget(FormMultiple oldWidget) {
    if (widget.values != oldWidget.values) {
      convertToItems(widget.values);
    }
    super.didUpdateWidget(oldWidget);
  }

  _onChanged(dynamic val, int index) {
    if(!_items.containsKey('${index + 1}'))_items['${index + 1}'] = <String, dynamic>{};
    if(_items['${index + 1}'] is Map){
      Map<String, dynamic> _temp = {};
      _items['${index + 1}'].forEach((k, v){
        _temp.addAll(<String, dynamic>{
          k.toString(): v
        });
      });
      _items['${index + 1}'] = _temp..addAll({
        'sortOrder': index + 1
      });
    }
    if(val is String){
      _items['${index + 1}'] = val;
    }
    else if(val is Map){
      val.forEach((key, value) {
        _items['${index + 1}'][key.toString()] = value.toString();
      });
      _items['${index + 1}']..addAll({
        'sortOrder': index + 1
      });
    }
    if(widget.onChanged != null)widget.onChanged!(_items);

  }

  @override
  Widget build(BuildContext context) {
    _count = !empty(_items) ? _items.length : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _count,
          itemBuilder: (_, index) {
            return Row(
              children: [
                Expanded(child: widget.builder((_items.values.elementAt(index) is String )?{
                  'sortOrder': index + 1,
                  'title': _items.values.elementAt(index)
                }:_items.values.elementAt(index), (val){
                  _onChanged(val, index);
                },index)),
                if (!widget.hideDelete && _count >= 2)
                  InkWell(
                    child: const Icon(Icons.delete, color: Colors.red),
                    onTap: (){
                      _remove(index);
                    },
                  ),
              ],
            );
          },
        ),
        if (!widget.hideAddNew)
          ButtonFlat(
            onPressed: () {
              _items['${_count + 1}'] = {};
              if (widget.onChanged != null) widget.onChanged!(_items);
              setState(() {});
            },
            color: !empty(widget.colorAdd)?widget.colorAdd:Theme.of(context).primaryColor,
            textColor: Theme.of(context).cardColor,
            child: Text(widget.titleAddNew!.lang()),
          ),
      ],
    );
  }

  _remove(int index) {
    List _temp = _items.values.toList();
    if(_temp.length == 1 && index == 0){
      _items = {
        '1': {}
      };
      if (widget.onChanged != null) widget.onChanged!(_items);
      if (widget.onReload != null) widget.onReload!();
    }else{
      int _int = 1;
      if (index < _temp.length) {
        _temp.removeAt(index);
        _items = Map.fromIterable(_temp,
            key: (e) {
              return (_int++).toString();
            },
            value: (e) => e);
        if (widget.onChanged != null) widget.onChanged!(_items);
        if (widget.onReload != null) widget.onReload!();
      }
    }
  }
}
