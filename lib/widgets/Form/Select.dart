import 'package:flutter/material.dart';
import 'package:vhv_basic/form.dart';
import 'package:vhv_basic/import.dart';
import 'dart:math';
import 'package:vhv_basic/widgets/NoData.dart';

class ChoiceStyle {
  const ChoiceStyle({
    this.shape,
    this.backgroundColor,
    this.color,
  });

  final OutlinedBorder? shape;
  final Color? backgroundColor;
  final Color? color;
}

class FormSelect extends StatefulWidget {
  final String? service;
  final Map<String, dynamic>? items;
  final dynamic value;
  final String? errorText;
  final String? labelText;
  final String? description;
  final Map<String, dynamic>? extraParams;
  final ValueChanged? onChanged;
  final ValueChanged? onTitleChanged;
  final String? searchBarHint;
  final InputDecoration? decoration;
  final Widget? trailing;
  final String? emptyDataText;
  final Duration? cacheTime;
  final bool enabled;
  final bool isMulti;
  final bool makeTree;
  final bool isChoice;
  final bool isCheckbox;
  final bool isRadio;
  final bool hideDescription;
  final bool showSearch;
  final bool isAutocomplete;
  final bool useSearchField;
  final bool isFront;
  final bool hasDividerCheckbox;
  final EdgeInsets? paddingCheckbox;
  final Function? itemsCallback;
  final Widget Function(Map item, ValueChanged onChanged, bool isSelected, bool isLast)?
  itemBuilder;
  final Function(dynamic title, dynamic keyword)? getTitle;
  final ChoiceStyle? choiceStyle;
  final bool isColumn;
  final bool isRadioBox;
  final String? defaultId;
  final String? fieldTitle;
  final BoxConstraints? suffixIconConstraints;
  final Function(Map item)? titleBuilder;

  const FormSelect({Key? key,
    this.makeTree = false,
    this.service,
    this.items,
    this.value,
    this.errorText,
    this.labelText,
    this.description,
    this.extraParams,
    this.onChanged,
    this.onTitleChanged,
    this.searchBarHint,
    this.decoration,
    this.trailing,
    this.suffixIconConstraints,
    this.emptyDataText,
    this.cacheTime,
    this.enabled = true,
    this.isMulti = false,
    this.isChoice = false,
    this.isCheckbox = false,
    this.isRadio = false,
    this.hideDescription = false,
    this.showSearch = true,
    this.isAutocomplete = false,
    this.itemBuilder,
    this.itemsCallback,
    this.useSearchField = false, this.getTitle, this.choiceStyle,
    this.isFront = true, this.hasDividerCheckbox = false, this.paddingCheckbox,
    this.isColumn = false, this.isRadioBox = false, this.defaultId, this.fieldTitle, this.titleBuilder})
      : super(key: key);

  @override
  _FormSelectState createState() => _FormSelectState();
}

class _FormSelectState extends State<FormSelect> {
  late _FormSelectController? controller;
  String? _controllerTag;
  String _key = '';
  final UniqueKey __key = UniqueKey();
  bool hasShowBottom = false;
  String labelText = '';

  @override
  void initState() {
    _key = '${(new DateTime.now()).microsecondsSinceEpoch}-${__key.toString()}';
    _controllerTag = 'FormSelect-${widget.service}-$_key';
    super.initState();
  }

  @override
  void dispose() {
    if (hasShowBottom) {
      appNavigator.pop();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FormSelect oldWidget) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (controller != null && mounted) {
        controller!.setValue(widget.value);
      }
    });
    if ((widget.extraParams.toString() != oldWidget.extraParams.toString()) &&
        controller != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (controller != null && mounted) {
          controller!.filters = {};
          controller!.setParams(widget.extraParams);
          controller!.selectAll();
        }
      });
    }
    if (widget.items != null && oldWidget.items != widget.items) {
      Future.delayed(const Duration(seconds: 1), () {
        if (controller != null && mounted) {
          controller!.setItems(widget.items!);
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_FormSelectController>(
      tag: _controllerTag,
      autoRemove: true,
      init: _FormSelectController(
          widget.service ?? '',
          fieldTitle: widget.fieldTitle,
          value: widget.value,
          tag: _controllerTag,
          cacheTime: widget.cacheTime,
          extraParams: widget.extraParams,
          description: (widget.description != null) ? widget.description : '',
          isChoice: widget.isChoice,
          hideDescription: widget.hideDescription,
          isCheckbox: widget.isCheckbox,
          isAutocomplete: widget.isAutocomplete,
          isColumn: widget.isColumn,
          isRadioBox: widget.isRadioBox,
          defaultId: widget.defaultId,
          titleBuilder: widget.titleBuilder,
          itemsInit: (!empty(widget.items))
              ? widget.items!.entries
              .map((entry) =>
          <String, dynamic>{
            'id': '${entry.key}',
            'title': '${entry.value}'
          }).toList() : null,
          isMulti: widget.isMulti
      ),
      builder: (_controller) {
        if (widget.itemsCallback != null)
          widget.itemsCallback!(_controller.items);
        _controller.getValue();
        String? _labelText = widget.labelText ?? widget.decoration?.labelText;
        controller = _controller;

        if (widget.isChoice) {
          return _ChoiceBuild(
            controller: _controller,
            parent: this.widget,
            onChanged: _onChanged,
          );
        }
        if (widget.isCheckbox) {
          return _CheckBoxBuild(
            controller: _controller,
            parent: this.widget,
            onChanged: _onChanged,
          );
        }
        if (widget.isColumn) {
          return _ColumnBuild(
            controller: _controller,
            parent: this.widget,
            onChanged: _onChanged,
          );
        }
        return InkWell(
          onTap: (!empty(widget.enabled))
              ? () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (Get.context!.mediaQueryViewInsets.bottom > 0)
              await Future.delayed(const Duration(seconds: 1));
            final _oldValue = _controller.getValue();
            if (!hasShowBottom) {
              hasShowBottom = true;
              await showBottomMenu(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: GetBuilder<_FormSelectController>(
                      tag: _controller.tag,
                      builder: (_controller) {
                        return Container(
                          constraints: BoxConstraints(
                              maxHeight:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height / 2),
                          child: Column(
                            children: [
                              if (widget.showSearch)
                                Stack(
                                  children: [
                                    TextFormField(
                                      initialValue: _controller.keyword,
                                      decoration: InputDecoration(
                                          suffixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                            borderRadius:
                                            new BorderRadius.circular(40),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                            borderRadius:
                                            new BorderRadius.circular(40),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                            borderRadius:
                                            new BorderRadius.circular(40),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.blue),
                                            borderRadius:
                                            new BorderRadius.circular(40),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                            borderRadius:
                                            new BorderRadius.circular(40),
                                          ),
                                          contentPadding: EdgeInsets.all(15)
                                              .copyWith(
                                              left: widget.isMulti ? 50 : 15),
                                          hintText: !empty(
                                              widget.useSearchField)
                                              ? 'Nhập mới hoặc chọn'
                                              : 'Tìm kiếm'.lang(),
                                          hintStyle:
                                          const TextStyle(fontSize: 16)),
                                      onChanged: (val) {
                                        if (widget.isAutocomplete) {
                                          _controller.searchByKeyword(
                                              'term', val.trim());
                                          _controller.setParams(
                                              {
                                                'term': val.trim(),
                                                'pageNo': 1
                                              });
                                          _controller.options['pageNo'] = 1;
                                        } else {
                                          _controller.searchLocal(val.trim());
                                        }
                                        if (widget.useSearchField) {
                                          widget.onChanged!(val.trim());
                                          _controller.setSearchField(val);
                                        }
                                      },
                                    ),
                                    if(widget.isMulti)Align(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(onPressed: () {
                                          _controller.setCheckAll();
                                        },
                                            icon: const Icon(
                                                Icons.check_circle_outline),
                                            color: _controller.hasCheckAll()
                                                ? Theme
                                                .of(context)
                                                .toggleableActiveColor
                                                : null))
                                  ],
                                ),
                              Flexible(
                                  child: ListViewBase(
                                      items: _controller.items ?? [],
                                      hasMax: _controller.hasMax,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: paddingBase),
                                      responsive: {
                                        DeviceType.tablet: !empty(
                                            widget.makeTree) ? 1 : 2
                                      },
                                      noData: NoData(
                                        msg: widget.emptyDataText,
                                      ),
                                      separatorBuilder: (_, __) {
                                        return const SizedBox.shrink();
                                      },
                                      detailBuilder: (item) {
                                        final double _level =
                                            parseDouble(item['level'], 1) -
                                                ((_controller.minLevel ?? 1) -
                                                    1.0);
                                        if (widget.itemBuilder != null)
                                          return widget.itemBuilder!(item,
                                                  (item) {
                                                _controller.changeValue(item);
                                                if (widget.onChanged != null)
                                                  _onChanged(
                                                      _controller.getValue());
                                              },
                                              _controller.checkValue(
                                                  _controller
                                                      .getValueItem(item)),
                                              _controller.checkLast(item));

                                        return Row(
                                          children: [
                                            if (widget.makeTree == true)
                                              SizedBox(
                                                width:
                                                ((max(_level, 1.0) - 1) *
                                                    30.0),
                                              ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: !empty(
                                                    item['disabled']) &&
                                                    item['disabled']
                                                        .toString() ==
                                                        '1'
                                                    ? null : () {
                                                  _controller
                                                      .changeValue(item);
                                                  // if(widget.onChanged != null)_onChanged(_controller!.getValue());
                                                  if (widget.getTitle != null) {
                                                    widget.getTitle!(
                                                        _controller.getTitle(),
                                                        !empty(
                                                            _controller.keyword)
                                                            ? _controller
                                                            .keyword
                                                            : '');
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 7),
                                                  child: Row(
                                                    children: [
                                                      _controller.checkValue(
                                                          _controller
                                                              .getValueItem(
                                                              item))
                                                          ? Icon(
                                                        (widget.isMulti ==
                                                            true)
                                                            ? Icons
                                                            .check_box
                                                            : Icons
                                                            .check_circle,
                                                        color: Theme
                                                            .of(
                                                            context)
                                                            .toggleableActiveColor,
                                                      )
                                                          : Icon((widget
                                                          .isMulti ==
                                                          true)
                                                          ? Icons
                                                          .check_box_outline_blank
                                                          : Icons
                                                          .radio_button_unchecked),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          controller!
                                                              .getTitleItem(
                                                              item),
                                                          style:
                                                          Theme
                                                              .of(context)
                                                              .textTheme
                                                              .subtitle1!
                                                              .copyWith(
                                                            color: _controller
                                                                .checkValue(
                                                                (item['id']
                                                                    ?.toString()))
                                                                ? Theme
                                                                .of(context)
                                                                .toggleableActiveColor
                                                                : null,
                                                            decoration: !empty(
                                                                item['disabled']) &&
                                                                item['disabled']
                                                                    .toString() ==
                                                                    '1'
                                                                ? TextDecoration
                                                                .lineThrough
                                                                : null,
                                                          ),
                                                        ),)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      onNext: (pageNo) {
                                        _controller.nextPage(pageNo);
                                      },
                                      pageNo: _controller.options['pageNo'],
                                      maxPage: _controller.maxPage))
                            ],
                          ),
                        );
                      },
                    ),
                  )
              );
              hasShowBottom = false;
            }
            if (widget.onChanged != null &&
                _oldValue != _controller.getValue()) {
              _onChanged(_controller.getValue());
            }
          }
              : null,
          child: Container(
            decoration: (empty(widget.enabled)
                ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.grey.withOpacity(0.1),
            )
                : null),
            child: TextFormField(
              controller: TextEditingController()
                ..text = empty(_controller.items) &&
                    widget.useSearchField &&
                    !empty(_controller.searchField)
                    ? _controller.searchField
                    : ((_controller.getTitle() ?? _labelText) ?? ''),
              enabled: false,
              maxLines: 1,
              decoration: (widget.decoration != null)
                  ? widget.decoration!.copyWith(
                errorText: !empty(widget.errorText)
                    ? widget.errorText!.lang()
                    : null,
                hintText: !empty(widget.description)
                    ? widget.description!.lang()
                    : null,
                labelText: !empty(_labelText) ? _labelText!.lang() : '',
                suffixIconConstraints: widget.suffixIconConstraints,
                suffixIcon:
                widget.trailing ?? const Icon(Icons.keyboard_arrow_down),
              )
                  : InputDecoration(
                // labelText: state.title,
                labelText: !empty(_labelText) ? _labelText!.lang() : null,
                errorText: !empty(widget.errorText)
                    ? widget.errorText!.lang()
                    : null,
                hintText: !empty(widget.description)
                    ? widget.description!.lang()
                    : null,
                border: const UnderlineInputBorder(borderSide: BorderSide()),
                suffixIcon:
                widget.trailing ?? const Icon(Icons.keyboard_arrow_down),
                errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red)),
                errorStyle: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }

  _onChanged(value) {
    if (widget.onChanged != null) widget.onChanged!(value);
    if (widget.onTitleChanged != null) widget.onTitleChanged!(
        controller?.getTitle());
  }
}

class _CheckBoxBuild extends StatelessWidget {
  const _CheckBoxBuild(
      {Key? key, required this.parent, required this.controller, required this.onChanged})
      : super(key: key);
  final FormSelect parent;
  final _FormSelectController controller;
  final Function(dynamic value) onChanged;


  @override
  Widget build(BuildContext context) {
    String? _labelText = parent.labelText ?? parent.decoration?.labelText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!empty(_labelText))
          Text(
            '$_labelText',
          ).marginOnly(bottom: 5),
        Column(
          children: controller.items?.map<Widget>((e) {
            final double _level =
                parseDouble(e['level'], 1) -
                    ((controller.minLevel ?? 1) -
                        1.0);

            if (parent.itemBuilder != null)
              return parent.itemBuilder!(e, (e) {
                controller.changeValue(e);
                if (parent.onChanged != null)
                  onChanged(controller.getValue());
              }, controller.checkValue(controller.getValueItem(e)),
                  controller.checkLast(e));
            return Row(
                children: [
                  if (parent.makeTree == true)
                    SizedBox(
                      width:
                      ((max(_level, 1.0) - 1) *
                          10.0),
                    ),
                  Expanded(
                    child: FormCheckbox(
                      enabled: parent.enabled,
                      padding: parent.isMulti ? null : parent.paddingCheckbox,
                      label: controller.getTitleItem(e),
                      value: controller.checkValue(controller.getValueItem(e)),
                      isFront: parent.isFront,
                      errorText: parent.errorText,
                      onChanged: (_selected) {
                        controller.changeValue(e);
                        onChanged(controller.getValue());
                      },
                      hasDivider: parent.hasDividerCheckbox,
                      isMulti: parent.isMulti,
                    ),
                  )
                ]
            );
          }).toList() ??
              [],
        ),
      ],
    );
  }
}

class _ColumnBuild extends StatelessWidget {
  const _ColumnBuild(
      {Key? key, required this.parent, required this.controller, required this.onChanged})
      : super(key: key);
  final FormSelect parent;
  final _FormSelectController controller;
  final Function(dynamic value) onChanged;


  @override
  Widget build(BuildContext context) {
    String? _labelText = parent.labelText ?? parent.decoration?.labelText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!empty(parent.labelText))
          Text(
            '$_labelText',
          ).marginOnly(bottom: 5),
        Container(
          child: Column(
            children: controller.items
                ?.map<Widget>(
                    (e) =>
                    Container(
                      child: ListTile(
                        onTap: () {
                          controller.changeValue(e);
                          if (parent.onChanged != null)
                            onChanged(controller.getValue());
                        },
                        title: Text('${e['title'] ?? ''}'),
                        trailing: controller.getValue() ==
                            e['id'].toString() ? Icon(
                          parent.isRadioBox
                              ? Icons.radio_button_on
                              : Icons.check_box,
                          color: Theme
                              .of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                        )
                            : Icon(
                          parent.isRadioBox
                              ? Icons.radio_button_off
                              : Icons.check_box_outline_blank,
                        ),
                      ),
                    )
            ).toList() ??
                [],
          ),
          color: Colors.white,
        ),
      ],
    );
  }
}

class _ChoiceBuild extends StatelessWidget {
  const _ChoiceBuild(
      {Key? key, required this.parent, required this.controller, required this.onChanged})
      : super(key: key);
  final FormSelect parent;
  final _FormSelectController controller;
  final Function(dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    String? _labelText = parent.labelText ?? parent.decoration?.labelText;
    Color _textColor = (!empty(Theme
        .of(context)
        .floatingActionButtonTheme
        .backgroundColor) &&
        Theme
            .of(context)
            .floatingActionButtonTheme
            .backgroundColor!
            .computeLuminance() <
            0.5)
        ? Colors.white
        : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!empty(_labelText))
          Text(
            '$_labelText',
          ).marginOnly(bottom: 5),
        Container(
          child: Wrap(
            spacing: 10,
            children: controller.items
                ?.map<Widget>(
                  (e) =>
              parent.isMulti
                  ? ChoiceChip(
                onSelected: parent.enabled ? (bool _selected) {
                  controller.changeValue(e);
                  if (parent.onChanged != null)
                    onChanged(controller.getValue());
                } : null,
                shape: parent.choiceStyle?.shape,
                backgroundColor: controller.checkValue(
                    controller.getValueItem(e))
                    ? Theme
                    .of(context)
                    .floatingActionButtonTheme
                    .backgroundColor
                    : (parent.choiceStyle?.backgroundColor ?? null),
                label: Text(
                  controller.getTitleItem(e),
                  style: TextStyle(
                      color: controller.checkValue(
                          controller.getValueItem(e))
                          ? _textColor
                          : null),
                ),
                selectedColor: controller.checkValue(
                    controller.getValueItem(e))
                    ? Theme
                    .of(context)
                    .floatingActionButtonTheme
                    .backgroundColor
                    : null,
                avatar: controller.checkValue(
                    controller.getValueItem(e))
                    ? Icon(
                  Icons.done,
                  color: _textColor,
                )
                    : null,
                selected: controller
                    .checkValue(controller.getValueItem(e)),
              )
                  : InputChip(
                onSelected: (bool _selected) {
                  controller.changeValue(e);
                  onChanged(controller.getValue());
                },
                isEnabled: parent.enabled,
                shape: parent.choiceStyle?.shape,
                backgroundColor: controller.checkValue(
                    controller.getValueItem(e))
                    ? Theme
                    .of(context)
                    .floatingActionButtonTheme
                    .backgroundColor
                    : (parent.choiceStyle?.backgroundColor ?? null),
                disabledColor: controller.checkValue(
                    controller.getValueItem(e)) ? Theme
                    .of(context)
                    .floatingActionButtonTheme
                    .backgroundColor : null,

                label: Text(
                  controller.getTitleItem(e),
                  style: TextStyle(
                      color: controller.checkValue(
                          controller.getValueItem(e))
                          ? _textColor
                          : (parent.choiceStyle?.color ?? null)),
                ),
                avatar: controller.checkValue(
                    controller.getValueItem(e))
                    ? Icon(
                  Icons.done,
                  size: 18,
                  color: _textColor,
                )
                    : null,
              ),
            ).toList() ??
                [],
          ),
        ),
      ],
    );
  }
}


class _FormSelectController extends GetBaseListController {
  final Duration? cacheTime;
  final String service;
  final Map<String, dynamic>? extraParams;
  final bool isMulti,
      isChoice,
      isCheckbox,
      hideDescription,
      isColumn,
      isRadioBox,
      isAutocomplete;
  final List? itemsInit;
  final String? description;
  final String? defaultId;
  final dynamic value;
  final String? fieldTitle;
  final Function(Map item)? titleBuilder;

  _FormSelectController(this.service,
      {this.isAutocomplete = false,
        this.titleBuilder,
        this.fieldTitle,
        this.value,
        this.tag,
        this.itemsInit,
        this.extraParams,
        this.cacheTime,
        this.isMulti = false,
        this.description,
        this.isChoice = false,
        this.hideDescription = false,
        this.isColumn = false,
        this.isCheckbox = false,
        this.isRadioBox = false, this.defaultId})
      : super(service,
      extraParams: extraParams,
      cacheTime: cacheTime ?? const Duration(minutes: 5),
      hasNow: false,
      forceRefresh: false,
      initNow: !isAutocomplete);

  final String? tag;
  String? _id;
  List? _ids;
  bool isCheckAll = false;
  String searchField = '';

  void setSearchField(String value) {
    searchField = value;
    update();
  }

  @override
  setOptions(Map<String, dynamic> _params) {
    if (isAutocomplete) {
      _params['itemsPerPage'] = 50;
    } else {
      _params['itemsPerPage'] = 100000;
    }

    return super.setOptions(_params);
  }

  _itemProcess(var items, [int level = 1]) {
    var _items = [];
    (items is Map ? items.values.toList() : items)?.forEach((element) {
      element.addAll(<String, dynamic>{'level': level});
      _items.add(element);
      if (!empty(element['items'])) {
        _items.addAll(_itemProcess(element['items'], level + 1));
      }
    });
    return _items;
  }

  @override
  prepareList(_res) {
    if (isAutocomplete) {
      if (_res is List && _res.isNotEmpty) {
        hasMax = false;
      }
    }
    bool hasNull = false;
    var _items = [];
    items?.forEach((element) {
      if (!empty(element['treeLevel'])) {
        element.addAll(<String, dynamic>{'level': element['treeLevel']});
      }
      if (empty(element['id'], true) && empty(element['code'], true)) {
        hasNull = true;
      }
      _items.add(element);
      if (!empty(element['items'])) {
        element.addAll(<String, dynamic>{'level': 1});
        _items.removeLast();
        _items.add(element);
        _items.addAll(_itemProcess(element['items'], 2));
      }
    });
    items = _items;
    if (!hideDescription && !hasNull && !isMulti && !isChoice && !isCheckbox &&
        !isColumn) {
      if (items == null) items = [];
      items!.insert(
          0, {
        'id': defaultId ?? '',
        'title': ((!empty(description) ? description : 'Chọn')!.lang())
      });
    }
    getItemsKey();

    if (isAutocomplete && keyword == null && !empty(value))
      keyword = getTitle();
    if (paging) {
      if (hasNow) {
        paging = false;
        update();
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          paging = false;
          update();
        });
      }
    } else {
      update();
    }
    if (isAutocomplete) {
      return super.prepareList(_res);
    }
    return null;
  }

  @override
  onInit() {
    if (!empty(itemsInit)) {
      items = itemsInit;
      getItemsKey();
    }
    if (isMulti) {
      _ids = [];
    } else {
      _id = '';
    }
    if (isAutocomplete) {
      if (!empty(value)) {
        setValue(value, false);
        selectAll(params: {'term': (value is List) ? value.join(',') : value});
      } else {
        selectAll();
      }
    } else {
      if (isset(value)) setValue(value);
    }
    super.onInit();
  }

  void setCheckAll() {
    var _all = items!.map<String>((e) {
      return (e['id'] ?? e['code']).toString();
    }).toList();
    if (_all.length > getValue().length) {
      setValue(_all);
    } else {
      setValue([]);
    }
    update();
  }

  @override
  nextPage(int pageNo) {
    if (!paging && ((maxPage != null && maxPage! >= pageNo) || !hasMax)) {
      setParams(<String, dynamic>{'pageNo': pageNo});
      return super.nextPage(pageNo);
    }
  }

  String? getTitle() {
    if (items != null && !empty(getValue(), true)) {
      return getTitleById(getValue(), true);
    }
    return description!.lang();
  }

  getValueItem(Map item) {
    final _val = item['id'] ?? item['code'];
    return _val.toString();
  }

  bool checkLast(Map item) {
    if (itemKeys == null) {
      return false;
    }
    final _val = item['id'] ?? item['code'];
    return (itemKeys!.indexOf(_val) == (itemKeys!.length - 1));
  }

  getTitleItem(Map item) {
    if (titleBuilder != null && !empty(getValueItem(item))) {
      return titleBuilder!(item);
    }
    return ((fieldTitle != null) ? item[fieldTitle] : null) ??
        ((item['title'] ?? item['label']) ?? '');
  }

  bool checkValue(dynamic id) {
    return (isMulti)
        ? (_ids != null ? _ids!.contains(id.toString()) : false)
        : (id.toString() == _id.toString());
  }

  bool hasCheckAll() {
    return (itemKeys!.length == getValue().length);
  }

  setValue(dynamic value, [bool _update = true]) {
    if (isMulti) {
      _ids = [];
      if (value == null) {
        _ids = [];
      } else {
        if (value is List) {
          value.forEach((element) {
            if (!_ids!.contains(element.toString())) {
              _ids!.add(element.toString().trim());
            }
          });
        } else if (value is String) {
          final _val = value.toString().split(',');
          _val.forEach((element) {
            if (!_ids!.contains(element.toString())) {
              _ids!.add(element.toString().trim());
            }
          });
        }
      }
    } else {
      if (value is String || value is num) {
        _id = value.toString();
      } else if (value is List && value.length > 0) {
        _id = value[0].toString();
      } else if (value == null) {
        _id = '';
      }
    }
    if (_update) update();
  }

  getValue() {
    return (isMulti) ? ([]..addAll(_ids!)) : _id;
  }

  changeValue(Map item) {
    final String _changeId = (item['id'] ?? item['code']).toString();
    if ((isMulti)) {
      if (_ids!.contains(_changeId)) {
        _ids!.remove(_changeId);
      } else {
        _ids!.add(_changeId);
      }
    } else {
      _id = _changeId;
      if (!isChoice && !isCheckbox && !isColumn) appNavigator.pop();
    }
    update();
  }

  setItems(Map<String, dynamic>? _items) {
    items = (!empty(_items))
        ? _items!.entries
        .map((entry) =>
    <String, dynamic>{
      'id': '${entry.key}',
      'title': '${entry.value}'
    })
        .toList()
        : null;
    getItemsKey();
    update();
  }
}
