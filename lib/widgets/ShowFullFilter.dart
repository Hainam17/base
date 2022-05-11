import 'package:flutter/material.dart';
import 'package:vhv_basic/libs/NavigatorLib.dart';

import '../import.dart';

showFullFilter<T extends GetxController>(
    {@required Widget Function(T controller) ?childBuilder,
      String? tagController,
      Function? onSearch,
      Function? onCancel,
      String? title,
      Widget? bottom,
      EdgeInsets? padding,
      ButtonStyle? styleButton,
      Color? backgroundColor}) async {
  final controller = Get.find<T>(tag: tagController);
  return await Get.to(() => BottomSheetMenuFull(
      backgroundColor: backgroundColor!,
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView(
                  // padding:EdgeInsets.only(
                  //     left: paddingBase,
                  //     right: paddingBase,
                  //     top: paddingBase + 5,
                  //     bottom: MediaQuery.of(currentContext)
                  //         .viewPadding
                  //         .bottom +
                  //         paddingBase),
                  children: [
                    GetBuilder<T>(
                      tag: tagController,
                      builder: (_controller) {
                        if (childBuilder != null) return childBuilder(controller);
                        return const SizedBox.shrink();
                      },
                    ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                  ],
                )),
            Padding(
                padding: padding ??
                    EdgeInsets.only(
                        left: paddingBase,
                        right: paddingBase,
                        top: 10,
                        bottom:
                        MediaQuery.of(currentContext).viewPadding.bottom +
                            paddingBase),
                child: (bottom != null)
                    ? bottom
                    : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: TextButton(
                          style: styleButton ??
                              TextButton.styleFrom(
                                backgroundColor: const Color(0xff005CB6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                          onPressed: () {
                            if (onSearch != null) onSearch(controller);
                            appNavigator.pop('onSearch');
                          },
                          child: Text(
                            'Áp dụng'.lang(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                          )),
                    ),
                    InkWell(
                      child: Container(
                        height: 5,
                        width: 135,
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xff000000),
                          borderRadius:
                          BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                      onTap: () {
                        appNavigator.pop();
                      },
                    )
                  ],
                )),
            // if(bottom != null)SizedBox(height: 10,),
          ],
        ),
      ),
      actionLeft: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          appNavigator.pop();
        },
      ),
      actionRight: (onCancel != null)
          ? TextButton(
          onPressed: () {
            // onCancel(controller);
            // controller.update();
            // appNavigator.pop('onCancel');
          },
          child: Text(
            'Đặt lại'.lang(),
            maxLines: 1,
          ))
          : SizedBox(),
      title: '${title ?? 'Bộ lọc'}'.lang()));
}

class BottomSheetMenuFull extends StatelessWidget {
  final Widget? child;
  final Widget? bottom;
  final dynamic title;
  final Widget actionRight;
  final Widget? actionLeft;
  final BottomSheetType type;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const BottomSheetMenuFull(
      {Key ?key,
        this.title,
         this.child,
         this.bottom,
         this.actionLeft,
         this.type = BottomSheetType.type1,
         this.backgroundColor,
         this.padding,
         required this.actionRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: (actionLeft != null) ? actionLeft : const SizedBox.shrink(),
        title: Text(title ?? ''),
        centerTitle: true,
        actions: <Widget>[actionRight],
        elevation: .5,
      ),
      backgroundColor: (backgroundColor != null)
          ? backgroundColor
          : Theme.of(context).cardColor,
      body: child,
    );
  }
}
