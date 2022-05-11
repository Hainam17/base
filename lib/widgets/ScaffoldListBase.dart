import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/libs/GetBaseListController.dart';
import 'package:vhv_basic/widgets/Button/Flat.dart';
import 'package:vhv_basic/widgets/ListViewBase.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'FilterBar/Default.dart';



class ScaffoldListBase<T extends GetBaseListController>
    extends StatelessWidget {
  final T? init;
  final String? id;
  final String? tag;
  final bool autoRemove;
  final bool assignId;

  ///Xây dựng 1 bản ghi trong danh sách
  ///onSelected => hàm gọi lựa chọn/bỏ lựa chọn bản ghi đó
  ///isSelected => check bản ghi có đang được lựa chọn hay không
  final Widget Function(
          T controller, Map item, VoidCallback onSelected, bool? isSelected)?
      detailBuilder;

  ///Danh sách các hành động xử lý nhiều lựa chọn (khuyến nghị sử dụng icon)
  final List<Widget> Function(T)? allActionBuilder;
  final bool Function(Map item)? conditionChecked;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  ///Tùy chỉnh khoảng phân chia giữa 2 bản ghi trong danh sách
  ///separatorBuilder(context, -1)->khoảng cách giữa 2 bản ghi/row
  final IndexedWidgetBuilder? separatorBuilder;

  ///Kiểu hiển thị không có dữ liệu
  final Widget? noData;

  ///Padding của danh sách
  final EdgeInsets? padding;

  final PreferredSizeWidget? appBar;
  final PreferredSizeWidget? Function(T)? appBarBuilder;
  final Widget? bottomNavigationBar;
  final Widget? Function(T)? bottomNavigationBarBuilder;
  final Function(T)? listViewBuilder;

  final bool hideAppbar;
  final bool? resizeToAvoidBottomInset;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget Function(T)? bottom;

  final Color? backgroundColor;

  final Widget Function(T)? header;
  final bool headerFix;
  final bool? headerFullWidth;

  ///Chiều cao tùy chỉnh của ô filter
  final double filterHeight;

  ///các lựa chọn xắp xếp (key là trường dữ liệu, value là tiêu đề)
  ///
  final Map<String, String>? sortOrderOptions;
  final bool isSortOrderParams;

  ///Tìm kiếm
  final ScaffoldListBaseFilter<T>? filter;

  ///Nút hành động nổi cơ bản
  final Widget? floatingActionButton;

  ///floating button tùy chỉnh khi cần dùng tới controller
  final ScaffoldListBaseFloating<T>? floatingButtonBuilder;

  final Map<DeviceSize, int>? responsive;
  final Map<DeviceSize, int> Function(T)? responsiveBuilder;

  final Widget? drawer;
  final Widget? endDrawer;
  final Key? key;
  final Widget Function(T)? bodyBuilder;
  final Widget Function(T)? bottomSheetBuilder;
  final Widget Function(T)? loadingBuilder;

  final Function(double pixel, bool isDown)? onScroll;
  final ShimmerOption? shimmerOption;




  const ScaffoldListBase(
      {this.key,
      this.onScroll,
      this.shimmerOption,
      this.init,
      this.id,
      this.tag,
      this.autoRemove = true,
      this.assignId = false,
      this.listViewBuilder,
      this.detailBuilder,
      this.shrinkWrap = false,
      this.physics,
      this.header,
      this.separatorBuilder,
      this.loadingBuilder,
      this.noData,
      this.padding,
      this.headerFix = false,
      this.headerFullWidth = false,
      this.hideAppbar = false,
      this.title,
      this.actions,
      this.bottomNavigationBar,
      this.allActionBuilder,
      this.floatingActionButton,
      this.filterHeight = 65.0,
      this.filter,
      this.bottom,
      this.floatingButtonBuilder,
      this.sortOrderOptions,
      this.isSortOrderParams = false,
      this.appBar,
      this.appBarBuilder,
      this.drawer,
      this.endDrawer,
      this.responsive,
      this.responsiveBuilder,
      this.resizeToAvoidBottomInset = true,
      this.backgroundColor,
      this.bodyBuilder,
      this.bottomSheetBuilder,
      this.conditionChecked, this.bottomNavigationBarBuilder});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      init: init,
      id: id,
      assignId: assignId,
      autoRemove: autoRemove,
      tag: tag,
      builder: (_controller) {
        if(!_controller.expansionVariable.containsKey('valueIsScrollDown')){
          _controller.expansionVariable['valueIsScrollDown'] = ValueNotifier(false);
        }
        if(!_controller.expansionVariable.containsKey('listScrollController')){
          _controller.expansionVariable['listScrollController'] = ScrollController();
        }
        if (_controller.conditionChecked == null && conditionChecked != null) {
          _controller.conditionChecked = conditionChecked!;
        }
        return Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          drawer: drawer,
          endDrawer: endDrawer,
          backgroundColor: backgroundColor,
          key: _controller.expansionVariable['globalScaffoldKey']??key,
          floatingActionButton: _floatingButton(_controller.expansionVariable['valueIsScrollDown']),
          floatingActionButtonAnimator: floatingButtonBuilder?.animator,
          floatingActionButtonLocation: floatingButtonBuilder?.location,
          bottomNavigationBar: (bottomNavigationBarBuilder != null)?bottomNavigationBarBuilder!(_controller):bottomNavigationBar,
          appBar: hideAppbar?null:((appBar != null || appBarBuilder != null)
              ? (!empty(_controller.selectedIds)
                  ? _header(context)
                  : ((appBarBuilder != null)
                      ? appBarBuilder!(_controller)
                      : appBar))
              : ((hideAppbar) ? null : _header(context))),
          body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (_controller.expansionVariable['valueIsScrollDown'] != null) {
                  if ((_controller.expansionVariable['listScrollController'].position.userScrollDirection ==
                      ScrollDirection.reverse &&
                      scrollNotification.metrics.pixels > (filterHeight))) {
                    _controller.expansionVariable['valueIsScrollDown']!.value = true;
                  } else if (_controller.expansionVariable['listScrollController'].position.userScrollDirection ==
                      ScrollDirection.forward) {
                    _controller.expansionVariable['valueIsScrollDown'].value = false;
                  }
                }
                if (onScroll != null &&
                    scrollNotification.metrics.axis == Axis.vertical) {
                  onScroll!(scrollNotification.metrics.pixels,
                      (_controller.expansionVariable['listScrollController'].position.userScrollDirection ==
                          ScrollDirection.reverse &&
                          scrollNotification.metrics.pixels > (filterHeight)));
                }
                return true;
              },
            child: RefreshIndicator(
              onRefresh: () async {
                await _controller.selectAll(clearCache: true);
              },
              child: bodyBuilder != null
                  ? bodyBuilder!(_controller)
                  : Stack(
                alignment: Alignment.topCenter,
                children: [
                  Builder(
                    builder: (_) {
                      _controller.hasPaddingBottom =
                      ((floatingActionButton != null ||
                          floatingButtonBuilder != null) &&
                          (_controller.indexMax ?? 0 + 1) ==
                              (_controller.items?.length));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(!empty(headerFix) && header != null)header!(_controller),
                          Expanded(child: LayoutBuilder(
                            builder: (_, __){
                              if (listViewBuilder != null &&
                                  listViewBuilder!(_controller) != null)
                                return listViewBuilder!(_controller);
                              return ListViewBase(
                                controller: _controller.expansionVariable['listScrollController'],
                                shimmerOption: shimmerOption,
                                headerFullWidth: headerFullWidth!,
                                // onRefresh: () async {
                                //   await _controller.selectAll(clearCache: true);
                                // },
                                loadingBuilder: loadingBuilder != null
                                    ? () {
                                  return loadingBuilder!(_controller);
                                }
                                    : null,
                                header: (header != null && !headerFix)
                                    ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (filter != null)
                                        SizedBox(
                                            height: filterHeight -
                                                (paddingBase * 2)),
                                      header!(_controller)
                                    ])
                                    : ((filter != null)
                                    ? SizedBox(
                                  height:
                                  filterHeight - (paddingBase * 2),
                                )
                                    : null),
                                physics: physics,
                                shrinkWrap: shrinkWrap,
                                separatorBuilder: separatorBuilder,
                                responsive: (responsiveBuilder != null)
                                    ? responsiveBuilder!(_controller)
                                    : responsive,
                                onRenderIndex: (index) {
                                  _controller.setFirstIndex(index);
                                },
                                items: _controller.items,
                                detailBuilder: (item) {
                                  return Theme(
                                    data: Theme.of(context),
                                    child: detailBuilder!(
                                        _controller,
                                        item,
                                        (allActionBuilder != null)
                                            ? () {
                                          _controller.onSelected(item['id']);
                                        }
                                            : () {},
                                        _controller.isSelected(
                                            item['id'].toString(), true, item)),
                                  );
                                },
                                onNext: (pageNo) => _controller.nextPage(pageNo),
                                pageNo: _controller.options['pageNo'],
                                maxPage: _controller.maxPage,
                                noData: noData,
                                padding: (padding ?? EdgeInsets.all(paddingBase))
                                    .copyWith(
                                    bottom: _controller.hasPaddingBottom
                                        ? 80
                                        : null),
                              );
                            },
                          ))
                        ],
                      );

                    },
                  ),
                  if (filter != null) _filterBuilder(context, _controller.expansionVariable['valueIsScrollDown']),
                ],
              ),
            ),
          ),
          bottomSheet: bottomSheetBuilder != null
              ? bottomSheetBuilder!(_controller)
              : null,
        );
      },
    );
  }

  ///bộ lọc
  Widget _filterBuilder(
      BuildContext context, ValueNotifier<bool> _isScrollDown) {
    final _controller = Get.find<T>(tag: tag);
    return ValueListenableBuilder<bool>(
        valueListenable: _isScrollDown,
        builder: (_, isScrollDown, child) {
          return AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: !isScrollDown
                  ? 0
                  : (((filterHeight * -1.0) - 10) -
                      Get.context!.mediaQueryViewPadding.top),
              left: 0,
              right: 0,
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: SafeArea(
                    child: Builder(
                        // height: filterHeight,
                        builder: (_) {
                      if (filter!.primaryFilter != null) {
                        return GetBuilder<T>(
                          tag: tag,
                          id: 'primaryFilter',
                          builder: (_controller){
                            return filter!.primaryFilter!(
                                _controller,
                                (filter!.extraBuilder != null)
                                    ? () async {
                                  showFilterBase(
                                    child: ValueListenableBuilder<
                                        Map<String, dynamic>>(
                                        valueListenable:
                                        _controller.tempFilters,
                                        builder: (_, value, child) {
                                          return filter!.extraBuilder!(
                                              _controller,
                                              value,
                                              _controller.setFilterTemp);
                                        }),
                                    onCancel: () async {
                                      await _controller.resetFilter();
                                    },
                                    onSearch: () async {
                                      await _controller.applyFilter();
                                    },
                                  );
                                }
                                    : () {},
                                sortOrderOptions != null
                                    ? () {
                                  showBottomMenu(
                                      title: 'Sắp xếp'.lang(),
                                      child: _buildSort(context));
                                }
                                    : () {}
                            );
                          },
                        );
                      }
                      return SizedBox(
                        height: filterHeight,
                        child: Builder(
                          builder: (_) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FilterBarDefault(
                                  child: _childFilterDefault(_controller),
                                  leading: (sortOrderOptions != null)
                                      ? SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: builderOrderByList(
                                                  !empty(_controller
                                                                  .options[
                                                              'orderBy'])
                                                      ? _controller
                                                          .options['orderBy']
                                                      : ''),
                                              onPressed: () {
                                                showBottomMenu(
                                                    title: 'Sắp xếp'.lang(),
                                                    child: _buildSort(context));
                                              }),
                                        )
                                      : null,
                                  initialValue: _controller.keyword?.trim(),
                                  labelText: filter!.labelText ?? 'Tìm kiếm',
                                  onChanged: (val) {
                                    _controller.keyword = val;
                                    _controller.searchByKeyword(
                                        '${filter!.searchField ?? 'filters[suggestTitle]'}',
                                        val.trim(),
                                        false);
                                  },
                                  onSearch: (val) async {
                                    await _controller.searchByKeyword(
                                        '${filter!.searchField ?? 'filters[suggestTitle]'}',
                                        val.trim(),
                                        true);
                                  },
                                  showSearch: (filter!.extraBuilder != null)
                                      ? () {
                                          showFilterBase(
                                            child: ValueListenableBuilder<
                                                    Map<String, dynamic>>(
                                                valueListenable:
                                                    _controller.tempFilters,
                                                builder: (_, value, child) {
                                                  return filter!.extraBuilder!(
                                                      _controller,
                                                      value,
                                                      _controller
                                                          .setFilterTemp);
                                                }),
                                            onCancel: () async {
                                              await _controller.resetFilter();
                                            },
                                            onSearch: () async {
                                              await _controller.applyFilter();
                                            },
                                          );
                                        }
                                      : null,
                                ),
                                if (filter!.extraPrimaryFilter != null)
                                  GetBuilder<T>(
                                    tag: tag,
                                    id: 'extraPrimaryFilter',
                                    builder: (_controller){
                                      return filter!.extraPrimaryFilter!(_controller);
                                    },
                                  )
                              ],
                            );
                          },
                        ),
                      );
                    }
                  ),
                )
              )
          );
        });
  }

  /// Appbar
  PreferredSizeWidget _header(BuildContext context) {
    final _controller = Get.find<T>(tag: tag);
    return factories['header'](context,
        automaticallyImplyLeading: empty(_controller.selectedIds),
        bottom: (bottom != null) ? bottom!(_controller) : null,
        title: (!empty(_controller.selectedIds))
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      await _controller.removeSelectedIds();
                    },
                  ),
                  Text('${_controller.selectedIds.length} mục')
                ],
              )
            : title,
        actions: (!empty(_controller.selectedIds) &&
                (allActionBuilder != null)
            ? allActionBuilder!(_controller)
            : <Widget>[])
          ..addAll((empty(_controller.selectedIds) && actions != null)
              ? actions!
              : [])
          ..addAll([
            if (_controller.items != null &&
                !empty(_controller.selectedIds) &&
                (_controller.selectedIds.length < _controller.items!.length))
              IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    _controller.checkAllIds();
                  }),
          ]));
  }

  ///Nút hành động nổi
  Widget _floatingButton(ValueNotifier<bool> _isScrollDown) {
    final _controller = Get.find<T>(tag: tag);
    return ValueListenableBuilder<bool>(
        valueListenable: _isScrollDown,
        builder: (_, isScrollDown, child) {
          if (floatingActionButton != null &&
              (_controller.hasPaddingBottom || !isScrollDown))
            return floatingActionButton!;
          if (floatingButtonBuilder != null &&
              (_controller.hasPaddingBottom || !isScrollDown))
            return floatingButtonBuilder!.button ??
                floatingButtonBuilder!.builder!(_controller);
          return const SizedBox.shrink();
        });
  }

  /// menu chọn kiểu xắp xếp
  Widget _buildSort(BuildContext context) {
    final controller = Get.find<T>(tag: tag);
    return Column(
        children: sortOrderOptions!.entries.map<Widget>((e) {
      return InkWell(
        onTap: () {
          if (isSortOrderParams) {
            if (controller.extraParams!.containsKey('orderBy')) {
              controller.extraParams!['orderBy'] = '${e.key}';
              controller.options['orderBy'] = '${e.key}';
            } else {
              controller.extraParams!.addAll({'orderBy': '${e.key}'});
              controller.options.addAll({'orderBy': '${e.key}'});
            }
          } else {
            if (controller.options['orderBy'] != null &&
                controller.options['orderBy'].endsWith('DESC')) {
              controller.options['orderBy'] = '${e.key} ASC';
            } else {
              controller.options['orderBy'] = '${e.key} DESC';
            }
          }
          appNavigator.pop();
          FocusScope.of(context).requestFocus(new FocusNode());
          controller.selectAll();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                  width: 40,
                  child: (controller.options['orderBy'] != null &&
                          controller.options['orderBy'].startsWith(e.key))
                      ? Icon(
                          controller.options['orderBy'].endsWith('DESC')
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 20)
                      : const SizedBox.shrink()),
              if (!empty(e.value))
                Expanded(
                    child: Text(e.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(currentContext).textTheme.subtitle1))
            ],
          ),
        ),
      );
    }).toList());
  }

  ///icon xắp xếp
  Widget builderOrderByList(String orderBy) {
    if (!empty(orderBy)) {
      return Icon(
          (orderBy.endsWith('DESC'))
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          size: 20);
    }
    return const Icon(
      Icons.sort,
      size: 18,
    );
  }

  _childFilterDefault(T _controller) {
    if ((hideAppbar && (appBar == null) && !empty(_controller.selectedIds))) {
      return Builder(builder: (_) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    await _controller.removeSelectedIds();
                  },
                ),
                Text('${_controller.selectedIds.length} mục')
              ],
            ),
            Positioned(
              right: 0,
              child: Row(
                children: (empty(_controller.selectedIds))
                    ? []
                    : (!empty(_controller.selectedIds) &&
                            (allActionBuilder != null)
                        ? allActionBuilder!(_controller)
                        : <Widget>[])
                  ..addAll((empty(_controller.selectedIds) && actions != null)
                      ? actions!
                      : [])
                  ..addAll([
                    if (_controller.items != null &&
                        !empty(_controller.selectedIds) &&
                        (_controller.selectedIds.length <
                            _controller.items!.length))
                      IconButton(
                          icon: Icon(Icons.select_all),
                          onPressed: () {
                            _controller.checkAllIds();
                          }),
                  ]),
              ),
            ),
          ],
        );
      });
    }
    return null;
  }
}

///Class cho nút hành động nổi
class ScaffoldListBaseFloating<T> {
  ///nút hành động cơ bản
  final Widget? button;

  ///vị trí của nút hành động
  final FloatingActionButtonLocation? location;
  final FloatingActionButtonAnimator? animator;

  ///Nút hành động tùy chỉnh đối với trường hợp có sử dụng controller
  final Widget Function(T)? builder;

  const ScaffoldListBaseFloating({
    this.animator,
    this.location,
    this.builder,
    this.button,
  }) : assert(button != null || builder != null,
            'Nút hành động bắt buộc phải có');
}

class ScaffoldListBaseFilter<T> {
  ///Placeholder của ô tìm kiếm
  final String? labelText;

  ///trường dữ liệu tìm kiếm
  final String? searchField;

  ///Tùy chỉnh ô tìm kiếm (chỉ nên áp dụng với trường hợp đặc biệt như là ô tìm kiếm kiểu select,...)
  ///Có sử dụng controller
  ///openExtraSearch => hàm để mở tìm kiếm nâng cao
  ///openSortOrder => hàm để mở menu chọn xắp xếp
  final Widget Function(T controller, VoidCallback openExtraSearch,
      VoidCallback openSortOrder)? primaryFilter;

  ///Tìm kiếm nâng cao
  final Widget Function(T controller, Map filters,
      Function(String key, dynamic value) onChanged)? extraBuilder;
  final Widget Function(T controller)? extraPrimaryFilter;

  const ScaffoldListBaseFilter(
      {this.primaryFilter,
      this.labelText,
      this.searchField,
      this.extraBuilder,
      this.extraPrimaryFilter});
}

showFilterBase(
    {@required Widget? child, Function? onSearch, Function? onCancel}) {
  showBottomMenu(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          child!,
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ButtonFlat(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                onPressed: () {
                  onSearch!();
                  appNavigator.pop('onSearch');
                },
                color: Theme.of(currentContext)
                            .floatingActionButtonTheme
                            .backgroundColor ==
                        null
                    ? Colors.blue
                    : Theme.of(currentContext)
                        .floatingActionButtonTheme
                        .backgroundColor as Color,
                textColor: Colors.white,
                child: Text('Áp dụng'.lang())),
          ),
        ],
      ),
      actionLeft: InkWell(
        child: const Padding(
            padding: EdgeInsets.only(left: 5), child: Icon(Icons.close)),
        onTap: () {
          appNavigator.pop();
        },
      ),
      actionRight: (onCancel != null)
          ? InkWell(
              onTap: () {
                onCancel();
                // appNavigator.pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  'Xóa'.lang(),
                  maxLines: 1,
                ),
              ))
          : null,
      title: 'Bộ lọc'.lang());
}
