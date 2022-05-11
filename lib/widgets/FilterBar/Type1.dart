import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:flutter/services.dart';

class FilterBarType1 extends StatelessWidget {
  final String? labelText;
  final ValueChanged? onChanged;
  final ValueChanged? onSearch;
  final Function()? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? initialValue;
  final Widget? leading;
  final child;

  const FilterBarType1(
      {Key? key,
        this.labelText,
        this.onChanged,
        this.showSearch,
        @required this.onSearch,
        this.color,
        this.actionsFilter, this.initialValue, this.leading, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(paddingBase),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          child: child??Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  padding: EdgeInsets.only(right: paddingBase, left: (leading != null)?0:paddingBase),
                  height: 35,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        (leading is Widget)
                            ?(leading!):Icon(
                          Icons.search,
                          size: 18,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: initialValue,
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              if (onSearch != null)
                                onSearch!(value);
                            },
                            onChanged: (val) {
                              if (onChanged != null)
                                onChanged!(val);
                            },
                            inputFormatters: [FilteringTextInputFormatter.deny(
                                new RegExp(r"\s{2,}\b|\b\s{2,}")
                            )],
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const
                                EdgeInsets.symmetric(vertical: 7),
                                border: InputBorder.none,
                                hintText: labelText ??
                                    'Tìm kiếm theo từ khóa'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showSearch != null)
                SizedBox(
                  height: 35,
                  width: 40,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.filter_list,
                        size: 20,
                      ),
                      onPressed: (){
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if(showSearch != null)showSearch!();
                      }),
                )
            ],
          ),
        ),
      ),
    );
  }
}
