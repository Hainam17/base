import 'package:flutter/material.dart';

import '../../global.dart';
AppBar headerDefault(BuildContext context, {
  Widget? bottom,
  Widget? title,
  Widget? leading,

  bool? centerTitle,
  double? elevation,
  List<Widget>? actions,
}){
  return AppBar(
    title: title??Text(app['title']),
    centerTitle: centerTitle,
    elevation: elevation,
    leading: leading,

    actions: actions??<Widget>[
      IconButton(
        icon: const Icon(Icons.notifications, size: 24),
        onPressed: () {
          appNavigator.pushNamed('/Notification');
        },
      ),
    ],
    bottom: (bottom != null)?PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Container(
        color: Theme.of(context).bottomAppBarColor,
        child: bottom,
      ),
    ):null,
  );
}