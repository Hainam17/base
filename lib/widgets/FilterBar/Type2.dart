import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/widgets/SvgViewer.dart';

class FilterBarType2 extends StatelessWidget {
  final String? labelText;
  final ValueChanged? onChanged;
  final ValueChanged? onSearch;
  final Function()? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? initialValue;
  final Widget? leading;
  final child;

  const FilterBarType2(
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
      margin: EdgeInsets.only(bottom: paddingBase),
      child: Material(
        elevation: 3,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingBase, vertical: 1).copyWith(bottom: 7),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: Color(0xffEDEDED)),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    initialValue: initialValue,
                    onChanged: (val){
                      if(onChanged != null)onChanged!(val);
                    },
                    onFieldSubmitted: (val){
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if(onSearch != null)onSearch!(val);
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(left: 40, top: 9, bottom: 9, right: (showSearch == null)?15:40),
                      hintText: labelText??'Tìm kiếm',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,

                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child:(leading != null)
                      ?leading:SizedBox(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: Icon(
                      Icons.search,
                      size: 18,
                  ),
                    ),
                      ),
                ),
                if(showSearch != null)Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: SvgViewer(
                        'assets/icons/ic_search_adv.svg',
                      color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                    ),
                    onPressed: showSearch,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
