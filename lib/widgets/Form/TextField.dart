
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_basic/helper.dart';

class FormTextField extends StatefulWidget {
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
  const FormTextField(
      {Key? key,this.value,this.onChanged,this.onFieldSubmitted,this.decoration,this.keyboardType,this.textCapitalization = TextCapitalization.none,
        this.enabled : true, this.autofocus : false,this.obscureText : false,this.readOnly : false, this.minLines, this.focusNode,
        this.maxLines, this.inputFormatters, this.maxLength = 255,this.textInputAction,this.style,
        this.textAlign = TextAlign.start})
      : super(key: key);
  @override
  _FormTextFieldState createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
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

  @override
  void didUpdateWidget(covariant FormTextField oldWidget) {
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
      child: TextFormField(
        style: widget.style,
        textAlign: widget.textAlign,
        maxLength: widget.enabled?widget.maxLength:null,
        inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
        minLines: widget.minLines,
        maxLines: widget.maxLines??1,
        enabled: widget.enabled,
        controller: _controller,
        onChanged: (val){
          value = val;
          if(widget.onChanged != null){
            widget.onChanged!(val);
          }
        },
        focusNode: widget.focusNode,
        textInputAction: widget.textInputAction,
        onEditingComplete: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        onFieldSubmitted: (val){
          FocusScope.of(context).requestFocus(new FocusNode());
          if(widget.onFieldSubmitted != null){
            widget.onFieldSubmitted!(val);
          }
        },
        onSaved: (val){
        },
        decoration: (widget.decoration != null && empty(widget.decoration!.counterText))?widget.decoration!.copyWith(
          counterText: '',
        ):widget.decoration,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        autofocus:widget.autofocus,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
      ),
    );
  }
}