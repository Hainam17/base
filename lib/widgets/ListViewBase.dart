import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/widgets/Loading.dart';
import 'package:vhv_basic/widgets/NoData.dart';
import 'package:vhv_basic/widgets/shimmer.dart';

class ShimmerOption{
  final Color? baseColor;
  final Color? highlightColor;
  final int counter;
  const ShimmerOption({this.counter = 20, this.baseColor, this.highlightColor});
}

class ListViewBase extends StatelessWidget {
  final List? items;
  final int? pageNo;
  final int? itemCount;
  final int? maxPage;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Function(Map item)? detailBuilder;
  final Widget? header;
  final bool headerFullWidth;
  final ValueChanged? onNext;
  final bool unsetPaddingTop;
  final IndexedWidgetBuilder? separatorBuilder;
  final bool? hasMax;
  final Axis scrollDirection;
  final ValueNotifier<bool>? isScrollDown;
  final Widget? noData;
  final Function? onRefresh;
  final EdgeInsets? padding;
  final double? scrollDownStart;
  final ValueChanged<int>? onRenderIndex;
  final Function(double pixel, bool isDown)? onScroll;
  final Map<DeviceSize, int>? responsive;
  final Widget Function()? loadingBuilder;
  final ScrollController? controller;
  final ShimmerOption? shimmerOption;

  ListViewBase(
      {Key? key,
        @required this.items,
        @required this.detailBuilder,
        @required this.onNext,
        @required this.pageNo,
        @required this.maxPage,
        this.loadingBuilder,
        this.unsetPaddingTop: false,
        this.separatorBuilder,
        this.onScroll,
        this.header,
        this.shrinkWrap = false,
        this.physics, this.hasMax, this.scrollDirection = Axis.vertical, this.isScrollDown, this.noData,
        this.onRefresh, this.padding, this.itemCount, this.scrollDownStart, this.onRenderIndex,
        this.responsive, this.headerFullWidth = false, this.controller, this.shimmerOption})
      : super(key: key);
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    int row = _checkRow(responsive);
    List? _items = items;
    if(!empty(shimmerOption) && items == null){
      _items = List.generate(shimmerOption!.counter, (index) => {});
    }
    int _length = (!empty(_items)) ? (_items!.length/row).ceil() : 0;
    if(header != null){
      _length++;
    }
    if(((_items?.length)??0) < 1 && header != null){
      _length++;
    }
    Widget _list = ListView.separated(
        controller: controller??((isScrollDown != null || onScroll != null)?_scrollController:null),
        padding: padding??(unsetPaddingTop
            ?EdgeInsets.all(paddingBase).copyWith(top: 0):EdgeInsets.all(paddingBase)),
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
        physics: physics ?? ((!isWeb && Platform.isIOS)?const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
            :const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics())),
        itemCount: itemCount ?? _length,
        separatorBuilder: separatorBuilder ??
                (_, __) {
              return SizedBox(
                height: paddingBase,
                width: paddingBase,
              );
            },
        itemBuilder: (context, index) {
          final int baseIndex = index;
          if(onRenderIndex != null)onRenderIndex!(index);
          if (header != null && index == 0) {
            return header as Widget;
          }
          if(header != null && index == 1 && empty(_items) && items == null){
            return noData??(factories['no-data'] ??const NoData());
          }
          if (header != null) index = index - 1;
          if(((_items?.length)??0) >= index + 1) {
            if(!empty(_items![index])) {
              _items[index]['listIndex'] = '${index + 1}';
            }
            if ((maxPage != null && maxPage! > pageNo!) ||
                (hasMax != null && !hasMax!)) {
              if ((baseIndex > _length - 5) && onNext != null) {
                onNext!(pageNo! + 1);
              }
              if (baseIndex == _length - 1) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildItem(context, _items, index, row),
                    const SizedBox(
                      height: 60,
                      child: const Center(
                        child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                      ),
                    ),
                  ],
                );
              }
            }
            return _buildItem(context, _items, index, row);
          }else{
            return noData??(factories['no-data'] ??const NoData());
          }
        });
    if(!empty(shimmerOption) && items == null){
      _list = Shimmer.fromColors(
          child: _list,
          baseColor: (shimmerOption!.baseColor)??Theme.of(context).cardColor,
          highlightColor: (shimmerOption!.highlightColor)??darken(Theme.of(context).cardColor)!
      );
    }
    if (_items != null) {
      if (_items.length > 0 || header != null) {
        if(isScrollDown != null || onScroll != null) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (isScrollDown != null) {
                if ((_scrollController.position.userScrollDirection ==
                    ScrollDirection.reverse &&
                    scrollNotification.metrics.pixels > (scrollDownStart ?? 10))) {
                  isScrollDown!.value = true;
                } else if (_scrollController.position.userScrollDirection ==
                    ScrollDirection.forward) {
                  isScrollDown!.value = false;
                }
              }
              if (onScroll != null &&
                  scrollNotification.metrics.axis == Axis.vertical) {
                onScroll!(scrollNotification.metrics.pixels,
                    (_scrollController.position.userScrollDirection ==
                        ScrollDirection.reverse &&
                        scrollNotification.metrics.pixels > (scrollDownStart ??
                            10)));
              }
              return true;
            },
            child: (onRefresh != null) ? RefreshIndicator(
                onRefresh: () async {
                  await onRefresh!();
                },
                child: (_items.length > 0) ? _list : noData ??
                    (factories['no-data'] ?? NoData())
            ) : _list,
          );
        }
        return (onRefresh != null) ? RefreshIndicator(
            onRefresh: () async {
              await onRefresh!();
            },
            child: (_items.length > 0) ? _list : noData ??
                (factories['no-data'] ?? const NoData())
        ) : _list;
      }
      return RefreshIndicator(
        child: noData??(factories['no-data'] ?? const NoData()),
        onRefresh: () async {
          await onRefresh!();
        },
      );
    }
    return (loadingBuilder != null)?loadingBuilder!():(factories['loading'] ?? const Loading());
  }
  Widget _buildItem(BuildContext context, List items, int startIndex, int row){
    if(row == 1){
      return detailBuilder!(items.elementAt(startIndex));
    }
    List<Widget> _list = [];
    for(int i = 0; i < row; i++){
      if(headerFullWidth && i == 0){
        _list.add((separatorBuilder != null) ? separatorBuilder!(context, -2):
        SizedBox(
          height: paddingBase,
          width: paddingBase,
        ));
      }
      if(i > 0){
        _list.add((separatorBuilder != null) ? separatorBuilder!(context, -1):
        SizedBox(
          height: paddingBase,
          width: paddingBase,
        ));

      }
      if(((row * startIndex) + i) < items.length) {
        _list.add(Expanded(
          child: detailBuilder!(!empty(items.elementAt((row * startIndex) + i))?({
            'fixFullHeight': 1
          }..addAll(items.elementAt((row * startIndex) + i))):items.elementAt((row * startIndex) + i)),
        ));
      }else{
        _list.add(Expanded(
          child: const SizedBox.shrink(),
        ));
      }
    }
    if(headerFullWidth){
      _list.add((separatorBuilder != null) ? separatorBuilder!(context, -2):
      SizedBox(
        height: paddingBase,
        width: paddingBase,
      ));
    }
    return Theme(
      data: ThemeData(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _list,
        ),
      ),
    );
  }

  int _checkRow(Map<DeviceSize, int>? responsive) {
    int? _row = Get.context!.isTablet?2:1;
    if(responsive != null){
      responsive.forEach((key, value) {
        final _min = key.minWidth??0;
        final _max = key.maxWidth??double.infinity;
        if(Get.width >= _min && _max >= Get.width){
          _row = value;
        }
      });
    }
    return _row??1;

  }
}


// enum DeviceType{
//   phone, largePhone, tablet, smallTablet, largeTablet,
// }
// bool get isPhone => (mediaQueryShortestSide < 600);
//
// /// True if the shortestSide is largest than 600p
// bool get isSmallTablet => (mediaQueryShortestSide >= 600);
//
// /// True if the shortestSide is largest than 720p
// bool get isLargeTablet => (mediaQueryShortestSide >= 720);
//
// /// True if the current device is Tablet
// bool get isTablet => isSmallTablet || isLargeTablet;
class DeviceType{
  DeviceType._();
  static const DeviceSize phone = DeviceSize(null, 480);
  static const DeviceSize largePhone = DeviceSize(480, 599);
  ///DeviceSize(600, 991)
  static const DeviceSize tablet = DeviceSize(600, 991);
  static const DeviceSize smallTablet = DeviceSize(600, 719);
  static const DeviceSize largeTablet = DeviceSize(720, 991);
  static const DeviceSize smallLaptop = DeviceSize(992, 1024);
  static const DeviceSize laptop = DeviceSize(1025, 1366);
  static const DeviceSize desktop = DeviceSize(1367, null);
  
  ///Exp: size = 300-400
  DeviceSize? operator [](String size) {
    if(size.contains('-')){
      final _size = size.split('-');
      return DeviceSize(parseDouble(_size[0]), parseDouble(_size[1]));
    }
    return null;
  }
}
class DeviceSize{
  final double? minWidth;
  final double? maxWidth;

  const DeviceSize([this.minWidth, this.maxWidth]);
}
