import 'package:flutter/material.dart';

import 'Checkbox.dart';

// ignore: must_be_immutable
class FormShowChecked extends StatefulWidget {
  final String label;
  final bool fullWidth;
  bool value;
  final Widget? child;
  final Function? onChanged;
  FormShowChecked({
    this.fullWidth:false,
    this.label:'',
    this.value:false,
    this.child,
    this.onChanged
  });
  @override
  _FormShowCheckedState createState() => _FormShowCheckedState();
}

class _FormShowCheckedState extends State<FormShowChecked> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FormCheckbox(
          fullWidth: widget.fullWidth,
          label: widget.label,
          value: widget.value,
          onChanged: (val) {
            setState(() {
              widget.value = val;
            });
            widget.onChanged!(val);
          },
        ),
        (widget.child != null && widget.value == true)?widget.child!:Container()
      ],
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}