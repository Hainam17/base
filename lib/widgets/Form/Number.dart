import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper/system.dart';

class FormNumber extends StatefulWidget {
  final dynamic value;
  final ValueChanged? onChanged;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final bool enabled;
  final bool autoFocus;
  final int minLines;
  final int maxLines;
  final int max;
  final int min;
  final int maxLength;
  final bool isCurrency;
  final bool useShortCurrency;
  final int mDec;
  final List<TextInputFormatter>? inputFormatters;

  const FormNumber({Key? key, this.value, this.max = 9999999999,this.min = 0, this.onChanged,
    this.decoration, this.keyboardType, this.textCapitalization, this.enabled = true,
    this.autoFocus = false, this.minLines = 1, this.maxLines = 1, this.maxLength = 13, this.inputFormatters,
    this.isCurrency = false, this.mDec = 0, this.useShortCurrency = false}) : super(key: key);
  @override
  _FormNumberState createState() => _FormNumberState();
}

class _FormNumberState extends State<FormNumber> {
  late RegExp _reg;
  late RegExp _reg2;
  String _val = '';
  final _controller = TextEditingController();
  @override
  void initState() {
    _reg = RegExp(r'(\d)(?=(\d{3})+$)');
    if(currentLanguage == 'vi') {
      _reg2 = RegExp(r'[^\d\,]+');
    }else{
      _reg2 = RegExp(r'[^\d\.]+');
    }
    _initVal();
    super.initState();
  }
  _initVal(){
    if (!empty(widget.value, true)) {
      final String _string = '${_formatNumber(widget.value.toString().replaceAll(_reg2, ''))}';
      _val = _string;
      _controller.value = TextEditingValue(
        text: _string,
        selection: TextSelection.collapsed(offset: _string.length),
      );
    }
  }
  @override
  void didUpdateWidget(FormNumber oldWidget) {
    _reg2 = RegExp(r'[^\d\.]+');
    if (widget.value != oldWidget.value) {
      _initVal();
    }
    super.didUpdateWidget(oldWidget);
  }

  String _formatNumber(String s){
    final _text = (currentLanguage == 'vi')?',':'.';
    String? _first;
    String? _last;
    if(s.indexOf(_text) != -1) {
      _first = s.substring(0, s.indexOf(_text));
      _last = s.substring(s.indexOf(_text));
    }else{
      _first = s;
    }
    if(_last != null && _last.lastIndexOf(_text) != 0){
      _last = _last.substring(0, _last.indexOf(_text, 1));
    }
    final newString = _first.replaceAllMapped(_reg, (match) {
      return '${match.group(1)}${(currentLanguage == 'vi')?'.':','}';
    });
    return '$newString${_last?.substring(0, (widget.mDec > 0?(widget.mDec + 1):widget.mDec))??''}';
  }
  @override
  Widget build(BuildContext context) {
    InputDecoration _deco = (widget.decoration??InputDecoration());
    return Container(
      decoration: (empty(widget.enabled) ? BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.grey.withOpacity(0.1),
      ) : null ),
      child: TextField(
        controller: _controller,
        decoration: (!empty(widget.isCurrency))?_deco.copyWith(suffixText: factories[widget.useShortCurrency?'shortCurrency':'currency']??'đ'):_deco,
        keyboardType: TextInputType.number,
        //maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters ?? <TextInputFormatter>[],
        minLines: widget.minLines,
        maxLines: 1,
        enabled: widget.enabled,
        textCapitalization: widget.textCapitalization??TextCapitalization.none,
        autofocus:widget.autoFocus,
        onChanged: (string) {
          if(parseInt(string.replaceAll(_reg2, '')) < widget.min){
            _val = widget.min.toString();
          }
          if(parseInt(string.replaceAll(_reg2, '')) > widget.max){
            _val = widget.max.toString();
          }

          else if(empty(widget.maxLength) || widget.maxLength >= string.replaceAll(_reg2, '').length){
            _val = string;
          }
          final String _string = '${_formatNumber(_val.replaceAll(_reg2, ''))}';
          _controller.value = TextEditingValue(
            text: _string,
            selection: TextSelection.collapsed(offset: _string.length),
          );
          if(widget.onChanged != null)widget.onChanged!(_val.replaceAll(_reg2, ''));
        },
      ),
    );
  }
}
