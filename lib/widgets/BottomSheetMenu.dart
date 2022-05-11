import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';

enum BottomSheetType{none, type1, type2}
class BottomSheetMenu extends StatelessWidget {
  final Widget? child;
  final Widget? bottom;
  final dynamic title;
  final Widget? actionRight;
  final Widget? actionLeft;
  final BottomSheetType? type;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  const BottomSheetMenu(
      {Key? key,
      this.title,
      this.child,
      this.bottom,
      this.actionRight,
      this.actionLeft, this.type = BottomSheetType.type1, this.backgroundColor, this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    BottomSheetType _type = type??BottomSheetType.type1;
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_type == BottomSheetType.type1)
            InkWell(
              child: Container(
                height: 6,
                width: 70,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              onTap: () {
                appNavigator.pop();
              },
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    color: backgroundColor??Theme.of(context).cardColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (type == BottomSheetType.type2)InkWell(
                        child: Container(
                          height: 5,
                          width: 50,
                          margin: const EdgeInsets.only(bottom: 5, top: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        onTap: () {
                          appNavigator.pop();
                        },
                      ),
                      if(title != null)Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 1.0,
                                color: const Color(0xffF1F1F1).withOpacity(0.5)),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            if (actionLeft != null)
                              actionLeft!,
                            Expanded(
                              child: Container(
                                color: Theme.of(context).cardColor,
                                padding: const EdgeInsets.all(10),
                                child: Center(
                                  child: title is Widget ? title : Text(
                                    '$title',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            if (actionRight != null)
                              actionRight!
                          ],
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: padding??EdgeInsets.only(
                              left: paddingBase,
                              right: paddingBase,
                              top: paddingBase + 5,
                              bottom: MediaQuery.of(context).viewPadding.bottom +
                                  paddingBase),
                          child: child,
                        ),
                      ),
                      if(bottom != null)bottom!
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
