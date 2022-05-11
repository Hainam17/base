import 'package:flutter/material.dart';

import '../import.dart';

class ItemListBase extends StatelessWidget {
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final EdgeInsetsGeometry? contentPadding;
  final List<ItemListAction>? actions;
  final bool? isSelected;
  final bool enabled;
  final Color? color;
  final bool isFullHeight;

  const ItemListBase({Key? key, this.onTap,
    @required this.title, this.leading,
    this.trailing, this.onLongPress,
    this.subtitle, this.actions, this.contentPadding, this.isSelected, this.enabled = true, this.color, this.isFullHeight = false}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color,
        child: InkWell(
        onTap: (isSelected != null)?onLongPress:onTap,
        child: Container(
          padding: contentPadding?? EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 10
          ).copyWith(right: (isSelected == null && actions != null)?0:10),
          constraints: BoxConstraints(
            minHeight: 45
          ),
          height: isFullHeight?double.infinity:null,
          child: Row(
              crossAxisAlignment: isFullHeight?CrossAxisAlignment.start:CrossAxisAlignment.center,
            children: [
              if(leading != null)leading!,
              if(leading != null)const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if(title != null)DefaultTextStyle(
                    child: title!,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  if(subtitle != null)DefaultTextStyle(
                    child: subtitle!,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.normal,
                      color: Theme.of(context).textTheme.bodyText1!.color?.withOpacity(0.8)
                    ),
                  )
                ],
              )),
              Builder(
                builder: (_){
                  if(isSelected != null){
                    if(isSelected!){
                      return Icon(Icons.check_circle_outline_outlined,
                        color: Theme.of(context).floatingActionButtonTheme.backgroundColor);
                    }else{
                      return const Icon(Icons.radio_button_unchecked);
                    }
                  }else{
                    if(!empty(actions)){
                      return IconButton(icon: const Icon(Icons.more_vert), onPressed: enabled?(){
                        showBottomMenu(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: actions!.map<Widget>((action){
                                return InkWell(
                                  onTap: (){
                                    appNavigator.pop();
                                    action.onTap!();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if(action.icon != null)IconTheme(
                                          child: action.icon!,
                                          data: IconThemeData(
                                              color: action.color
                                          ),
                                        ),
                                        if(action.icon != null && action.title != null)const SizedBox(width: 10),
                                        if(action.title != null)Text(lang(action.title!), style: Theme.of(context).textTheme.subtitle1!.copyWith(color: action.color)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                        );
                      }:null);
                    }
                  }
                  if(trailing != null){
                    return trailing!;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        onLongPress: onLongPress,
      )
    );
  }
}
class ItemListAction{
  final Widget? icon;
  final String? title;
  final GestureTapCallback? onTap;
  final Color? color;

  ItemListAction({this.color, this.icon, this.title,@required this.onTap});
}
