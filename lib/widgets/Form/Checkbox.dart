import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

// ignore: must_be_immutable
class FormCheckbox extends StatefulWidget {
  bool value;
  final dynamic label;
  final ValueChanged? onChanged;
  final Color? bgColor;
  final EdgeInsets? padding;
  final bool fullWidth;
  final bool isFront;
  final bool enabled;
  final bool hasDivider;
  final bool isMulti;
  final String? errorText;
  final TextStyle? textStyle;

  FormCheckbox({this.label,
    this.value: false,
    this.onChanged,
    this.bgColor,
    this.padding,
    this.errorText,
    this.textStyle,
    this.fullWidth: true, this.enabled: true, this.isFront: false, this.hasDivider = false, this.isMulti = false
  });

  @override
  _FormCheckboxState createState() => _FormCheckboxState();
}

class _FormCheckboxState extends State<FormCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: (widget.bgColor != null) ? widget.bgColor : Colors.transparent,
          padding: (widget.padding != null) ? widget.padding : null,
          child: Row(
            crossAxisAlignment: (widget.fullWidth == true) ? CrossAxisAlignment
                .center : CrossAxisAlignment.center,
            mainAxisAlignment: (widget.fullWidth == true) ? MainAxisAlignment
                .spaceBetween : MainAxisAlignment.start,
            mainAxisSize: widget.fullWidth == true
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: <Widget>[
              (widget.isFront) ? SizedBox(
                height: 35,
                width: 30,
                child: Theme(
                  // Create a unique theme with "ThemeData"
                  data: ThemeData(
                    unselectedWidgetColor: (!empty(widget.errorText)) ? Theme
                        .of(context)
                        .errorColor : Theme
                        .of(context)
                        .unselectedWidgetColor,
                    checkboxTheme: Theme.of(currentContext).checkboxTheme
                  ),
                  child: Checkbox(
                      value: widget.value,
                      onChanged: (widget.enabled) ? (val) {
                        if (widget.onChanged != null) {
                          widget.onChanged!(val);
                          setState(() {
                            widget.value = val!;
                          });
                        }
                      } : null
                  ),
                ),
              ) : SizedBox(),
              (widget.fullWidth == true) ?
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: widget.label is String ? Text(
                    widget.label!,
                    style: widget.textStyle ?? const TextStyle(fontSize: 14),
                  ) : widget.label!,
                ),
              )
                  : Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: widget.label is String ? Text(
                    widget.label!,
                    style: widget.textStyle
                ) : widget.label!,
              ),
              (!widget.isFront) ? SizedBox(
                height: 35,
                width: 30,
                child: Theme(
                  // Create a unique theme with "ThemeData"
                  data: ThemeData(
                    unselectedWidgetColor: (!empty(widget.errorText)) ? Theme
                        .of(context)
                        .errorColor : Theme
                        .of(context)
                        .unselectedWidgetColor,
                    checkboxTheme: CheckboxThemeData(
                        shape: RoundedRectangleBorder(
                            borderRadius: !widget.isMulti ? BorderRadius
                                .circular(25) : BorderRadius.zero)),
                  ),
                  child: Checkbox(
                      value: widget.value,
                      onChanged: (widget.enabled) ? (val) {
                        if (widget.onChanged != null) {
                          widget.onChanged!(val);
                          setState(() {
                            widget.value = val!;
                          });
                        }
                      } : null
                  ),
                ),
              ) : const SizedBox()
            ],
          ),
        ),
        if(widget.hasDivider) const Divider(height: 1),
      ],
    );
  }
}
