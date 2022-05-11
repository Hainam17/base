import 'package:flutter/material.dart';

import 'Select.dart';

class FormBirthYear extends StatefulWidget {
  final String? label, errorText, value, description;
  final Function onChanged;
  final bool enabled;
  final InputDecoration? decoration;

  const FormBirthYear({Key? key, this.label, this.errorText,this.description,
    required this.onChanged, this.value,this.enabled:true,this.decoration}) : super(key: key);
  @override
  _FormBirthYearState createState() => _FormBirthYearState();
}

class _FormBirthYearState extends State<FormBirthYear> {
  String _value = '';
  final _year = DateTime.now().year;
  String? _errorText;
  @override
  void initState() {
    _value = widget.value!;
    _errorText = widget.errorText;
    super.initState();
  }
  @override
  void didUpdateWidget(FormBirthYear oldWidget) {
    _value = (widget.value)??_value;
    _errorText = widget.errorText;
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    _value = (widget.value)??_value;
    return Container(
      child: _buildSelect(),
    );
  }
  Widget _buildSelect(){
    Map<String, String>_years = {};
    int _min = _year - 110;
    for(int i = _year; i >= _min; i--){
      _years.putIfAbsent(i.toString(), () => i.toString());
    }
    return FormSelect(
      enabled: widget.enabled,
      labelText: widget.label,
      description: widget.description,
      errorText: _errorText,
      value: _value,
      items: _years,
      onChanged: (val){
        widget.onChanged(val);
        // setState(() => _value = val);
      },
      decoration: widget.decoration,
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}