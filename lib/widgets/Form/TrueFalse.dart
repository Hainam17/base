import 'package:flutter/material.dart';

class FormTrueFalse extends StatefulWidget {
  final bool? groupValue;
  final ValueChanged<bool?>? onChanged;
  final String textTrue;
  final String textFalse;
  final Widget? trueWidget;
  final Widget? falseWidget;
  final bool enabled;

  const FormTrueFalse({Key? key, this.groupValue, this.onChanged, this.textTrue = 'T',
    this.textFalse = 'F',
    this.trueWidget, this.falseWidget, this.enabled = true}) : super(key: key);
  @override
  _FormTrueFalseState createState() => _FormTrueFalseState();
}

class _FormTrueFalseState extends State<FormTrueFalse> {
  bool? _value;
  @override
  void initState() {
    _value = widget.groupValue;
    super.initState();
  }
  @override
  void didUpdateWidget(covariant FormTrueFalse oldWidget) {
    _value = widget.groupValue;
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return _buildTrueFalse(groupValue: _value, onChanged: widget.onChanged);
  }
  Widget _buildTrueFalse({bool? groupValue, ValueChanged<bool?>? onChanged}){
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: (groupValue != null && groupValue == true)?(widget.enabled?Theme.of(context).toggleableActiveColor
                    :Theme.of(context).disabledColor):null,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                (widget.trueWidget != null)?IconTheme(
                  data: IconThemeData(
                    color: (groupValue != null && groupValue == true)?Colors.white:null
                  ),
                  child: widget.trueWidget!,
                ):Text(widget.textTrue, style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w500,color: (groupValue != null && groupValue == true)?Colors.white:null)),
                Opacity(
                  opacity: 0,
                  child: Radio(value: true, groupValue: groupValue, onChanged: widget.enabled?(val){
                    if(onChanged != null)onChanged(val as bool);
                    if(onChanged != null)setState(() {
                      _value = val as bool;
                    });
                  }:null),
                ),
              ],
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: (groupValue != null && groupValue == false)
                    ?(widget.enabled?Theme.of(context).toggleableActiveColor
                    :Theme.of(context).disabledColor):null,
                borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                (widget.falseWidget != null)?IconTheme(
                  data: IconThemeData(
                      color: (groupValue != null && groupValue == false)?Colors.white:null
                  ),
                  child: widget.falseWidget!,
                ):Text(widget.textFalse, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: (groupValue != null && groupValue == false)?Colors.white:null)),
                Opacity(
                  opacity: 0,
                  child: Radio(value: false, groupValue: groupValue, onChanged: widget.enabled?(val){
                    if(onChanged != null)onChanged(val as bool);
                    if(onChanged != null)setState(() {
                      _value = val as bool;
                    });
                  }:null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}