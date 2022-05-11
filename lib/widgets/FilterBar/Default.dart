import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/widgets/FilterBar/Type2.dart';

import 'Type1.dart';
class FilterBarDefault extends StatelessWidget {
  final String? labelText;
  final ValueChanged? onChanged;
  final ValueChanged? onSearch;
  final Function()? showSearch;
  final Color? color;
  final Widget? actionsFilter;
  final String? initialValue;
  final Widget? leading;
  final child;

  const FilterBarDefault(
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
    switch(factories['filterBarType']){
      case FilterBarType.Type2:
        return FilterBarType2(
          labelText: labelText,
          onSearch: onSearch,
          onChanged: onChanged,
          showSearch: showSearch,
          color: color,
          actionsFilter: actionsFilter,
          initialValue: initialValue,
          leading: leading,
          child: child,
        );
      default:
        return FilterBarType1(
          labelText: labelText,
          onSearch: onSearch,
          onChanged: onChanged,
          showSearch: showSearch,
          color: color,
          actionsFilter: actionsFilter,
          initialValue: initialValue,
          leading: leading,
          child: child,
        );
    }
  }
}
