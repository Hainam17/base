import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

// ignore: must_be_immutable
class FormRadio extends StatefulWidget {
  final Function? onChanged;
  final Map<String, dynamic>? listValues;
  String? value;
  final double space;
  final Axis direction;
  final bool enabled;
  final String? errorText;
  final Alignment? alignment;

  FormRadio(
      {Key? key,
      this.onChanged,
      this.listValues,
      this.errorText,
      this.value: '',
      this.enabled: true,
      this.space: 10.0, this.alignment,
      this.direction: Axis.horizontal})
      : super(key: key);
  @override
  _FormRadioState createState() => _FormRadioState();
}

class _FormRadioState extends State<FormRadio> {
  @override
  Widget build(BuildContext context) {
    return _listRadio();
  }

  Widget _listRadio() {
    List<Widget> _list = <Widget>[];
    int i = 1;
    widget.listValues!.forEach((key, value) {
      _list.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 30,
            width: 30,
            child: Theme(
              // Create a unique theme with "ThemeData"
              data: ThemeData(
                  unselectedWidgetColor: (!empty(widget.errorText))?Theme.of(context).errorColor:Theme.of(context).unselectedWidgetColor,
              ),
              child: Radio(
                  value: key,
                  groupValue: widget.value,
                  onChanged: (widget.enabled)
                      ? (val) {
                    if(widget.onChanged != null) {
                      widget.onChanged!(val);
                      setState(() {
                        FocusScope.of(context)
                            .requestFocus(new FocusNode());
                        widget.value = val as String;
                      });
                    }
                        }
                      : null),
            ),
          ),
          Flexible(child: Text(value.toString())),
        ],
      ));
      if (i < widget.listValues!.length) {
        _list.add(SizedBox(
          width: (widget.direction == Axis.horizontal)?widget.space:0,
          height: (widget.direction == Axis.vertical)?widget.space:0,
        ));
      }
      i++;
    });
    if (widget.direction == Axis.vertical) {
      return Align(
        alignment: widget.alignment??Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _list,
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.start,
      children: _list,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
