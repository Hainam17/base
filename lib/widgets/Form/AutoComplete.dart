import 'package:flutter/material.dart';
import 'package:vhv_basic/widgets/Form/Select.dart';

class FormAutoComplete extends FormSelect {
  final String? service;
  final Map<String, String>? items;
  final dynamic value;
  final String? errorText;
  final String? labelText;
  final String? description;
  final Map<String, dynamic>? extraParams;
  final ValueChanged? onChanged;
  final String? searchBarHint;
  final InputDecoration? decoration;
  final Widget? trailing;
  final String? emptyDataText;
  final Duration? cacheTime;
  final bool enabled;
  final bool hasTrans;
  final bool isMulti;
  final String? fieldTitle;
  final Function(dynamic title, dynamic keyword)? getTitle;

  FormAutoComplete(
      {Key? key,
        this.service,
        this.items,
        this.errorText,
        this.labelText,
        this.description,
        this.extraParams,
        this.onChanged,
        this.searchBarHint,
        this.decoration,
        this.emptyDataText,
        this.value,
        this.fieldTitle,
        this.enabled = true,
        this.cacheTime: const Duration(minutes: 5),
        this.trailing, this.hasTrans = false, this.isMulti = false, this.getTitle})
      : super(key: key, isMulti: isMulti, isAutocomplete: true, service: service, items: items,
      value: value, errorText: errorText, labelText: labelText,
      decoration: decoration, description: description, enabled: enabled, extraParams: extraParams,
      searchBarHint: searchBarHint, trailing: trailing, emptyDataText: emptyDataText,
      cacheTime: cacheTime, getTitle: getTitle, fieldTitle: fieldTitle);
}