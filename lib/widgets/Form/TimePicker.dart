import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/widgets/TimePicker.dart';

class FormTimePicker extends StatefulWidget {
  final String? value;
  final ValueChanged? onChanged;
  final ValueChanged? onFieldSubmitted;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  const FormTimePicker(
      {Key? key,this.value,this.onChanged,this.onFieldSubmitted,this.decoration,this.keyboardType,this.textCapitalization = TextCapitalization.none,
        this.enabled : true, this.autofocus : false,this.obscureText : false,this.readOnly : false, this.minLines, this.focusNode,
        this.maxLines, this.inputFormatters, this.maxLength,this.textInputAction,this.style,
        this.textAlign = TextAlign.start})
      : super(key: key);
  @override
  _FormTimePickerState createState() => _FormTimePickerState();
}

class _FormTimePickerState extends State<FormTimePicker> {
  TextEditingController? _controller;
  String? value;
  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = new TextEditingController(text: widget.value ?? '');
    super.initState();
  }
  _onChanged(String val){
    _controller!.text = val;
    if(widget.onChanged != null){
      widget.onChanged!(val);
    }
  }

  @override
  void didUpdateWidget(covariant FormTimePicker oldWidget) {
    if (widget.value != oldWidget.value && widget.value != value) {
      _controller!.text = widget.value!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: (empty(widget.enabled) ? BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.grey.withOpacity(0.1),
      ) : null ),
      child: GestureDetector(
        onTap: widget.enabled?()async{
          await showBottomMenu(
              child: TimePicker(
                onChanged: _onChanged,
                value: _controller!.text ,
              )
          );
        }:null,
        child: TextFormField(
          style: widget.style,
          textAlign: widget.textAlign,
          maxLength: widget.enabled?widget.maxLength:null,
          inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
          minLines: widget.minLines,
          maxLines: widget.maxLines??1,
          controller: _controller,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          enabled: false,
          decoration: widget.decoration,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          autofocus:widget.autofocus,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
        ),
      ),
    );
  }
}