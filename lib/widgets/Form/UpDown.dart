import 'package:flutter/material.dart';
import 'package:vhv_basic/import.dart';

class FormUpDown extends StatefulWidget {
  final int? value;
  final int min;
  final int max;
  final ValueChanged? onChanged;

  const FormUpDown({Key? key, this.value, this.min = 0, this.max = 100000, this.onChanged}) : super(key: key);
  @override
  _FormUpDownState createState() => _FormUpDownState();
}

class _FormUpDownState extends State<FormUpDown> {
  int _value = 0;
  @override
  void initState() {
    _value = widget.value??widget.min;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: (){
            if(_value > (widget.min))setState(() {
              _value--;
            });
            _onchange(_value);
          },
          icon: SvgViewer('assets/icons/ic_subtract.svg', package: 'vhv_basic',
            color: Theme.of(context).unselectedWidgetColor.withOpacity((_value > widget.min)?0.7:0.3)),
        ),
        Container(
          constraints: BoxConstraints(
            minWidth: 30
          ),
          child: Text('$_value', style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center),
        ),
        IconButton(
          onPressed: (){
            if(_value < widget.max)setState(() {
              _value++;
            });
            _onchange(_value);
          },
          icon: SvgViewer('assets/icons/ic_add.svg', package: 'vhv_basic',
            color: Theme.of(context).unselectedWidgetColor.withOpacity((_value < widget.max)?0.7:0.3)),
        )
      ],
    );
  }
  _onchange(val){
    if(widget.onChanged != null)widget.onChanged!(_value);
  }
}
