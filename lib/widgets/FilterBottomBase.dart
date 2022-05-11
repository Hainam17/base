import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/extension/string_extension.dart';

class FilterBottomBase extends StatefulWidget {
  final Widget? child;
  final Function? onSearch;
  final Function(Function)? reloadCallback;
  const FilterBottomBase({Key? key, this.child, this.onSearch, this.reloadCallback}) : super(key: key);

  @override
  _FilterBottomBaseState createState() => _FilterBottomBaseState();
}

class _FilterBottomBaseState extends State<FilterBottomBase> {
  @override
  Widget build(BuildContext context) {
    if(widget.reloadCallback != null)widget.reloadCallback!(()=>setState(() {

    }));
    return Container(
      key: UniqueKey(),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          widget.child!,
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(currentContext).floatingActionButtonTheme.backgroundColor),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
                ),
                onPressed: () {
                  if(widget.onSearch != null)widget.onSearch!();
                  appNavigator.pop('onSearch');
                },
                child: Text('Áp dụng'.lang())),
          ),
        ],
      ),
    );
  }
}
