import 'package:flutter/material.dart';

class ButtonBase extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final VoidCallback? onPressed;
  final double? height;
  const ButtonBase({Key? key,required this.child,required this.onPressed,this.icon, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height??40,
      width: double.infinity,
      child: icon != null?TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor??Colors.blue,
            primary: Colors.white,
          ),
          label: child,
          icon: icon!,
          onPressed: onPressed
      ):TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor??Colors.blue,
            primary: Colors.white,
          ),
          child: child,
          onPressed: onPressed
      ),
    );
  }
}