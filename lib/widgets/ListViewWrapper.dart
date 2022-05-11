import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class ListViewWrapper<T extends GetBaseListController> extends StatelessWidget {
  final T? init;
  final String? id;
  final String? tag;
  final bool autoRemove;
  final bool assignId;
  final Widget Function(T controller, Map item)? detailBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget Function(T controller)? header;
  final bool headerFix;
  final bool unsetPaddingTop;
  final IndexedWidgetBuilder? separatorBuilder;
  final Axis scrollDirection;
  final ValueNotifier<bool>? isScrollDown;
  final Widget? noData;
  final EdgeInsets? padding;
  final bool hasRefresh;
  final Map<DeviceSize, int>? responsive;
  const ListViewWrapper({Key? key, this.init, this.id, this.tag, this.autoRemove = true,
  this.assignId = false, @required this.detailBuilder, this.shrinkWrap = false, this.physics, this.header,
    this.unsetPaddingTop = false, this.separatorBuilder, this.scrollDirection = Axis.vertical,
    this.isScrollDown, this.noData, this.padding, this.hasRefresh = false, this.headerFix = false, this.responsive}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      init: init,
      id: id,
      assignId: assignId,
      autoRemove: autoRemove,
      tag: tag,
      builder: (_controller){
        Widget _list = ListViewBase(
          header: (header != null && !headerFix)?header!(_controller):null,
          physics: physics,
          responsive: responsive,
          shrinkWrap: shrinkWrap,
          unsetPaddingTop: unsetPaddingTop,
          scrollDirection: scrollDirection,
          separatorBuilder: separatorBuilder,
          onRefresh: hasRefresh?_controller.selectAll():null,
          items: _controller.items,
          detailBuilder: (item){
            return detailBuilder!(_controller, item);
          },
          onNext: (pageNo) => _controller.nextPage(pageNo),
          pageNo: _controller.options['pageNo'],
          maxPage: _controller.maxPage,
          noData: noData,
          padding: padding,
        );
        if(!empty(headerFix) && header != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header!(_controller),
              Expanded(child: _list)
            ],
          );
        }
        return _list;
      },
    );
  }
}

