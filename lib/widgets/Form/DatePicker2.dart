//import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:vhv_basic/extension/string_extension.dart';
//import 'package:vhv_basic/global.dart';
//import 'package:vhv_basic/helper/system.dart';
//
//class FormDatePicker2 extends StatefulWidget {
//  FormDatePicker2({
//    this.onDateSelected,
//    this.selectedDate,
//    this.firstDate,
//    this.lastDate,
//    this.initialDatePickerMode = DatePickerMode.day,
//    this.decoration,
//    this.label,
//    this.errorText,
//    this.dateFormat,
//    this.showTime = false,
//    this.showTimePicker = false,
//    this.selectDate = false,
//    this.onChanged,
//    this.hintText = 'Chọn',
//    this.locale,
//    this.enabled: true,
//    this.hiddenSuffixIcon: false,
//    this.cancel
//  });
//
//  final ValueChanged<DateTime> onDateSelected;
//  final ValueChanged<String> onChanged;
//  final Function cancel;
//  final bool showTime;
//  final bool showTimePicker;
//  final bool selectDate;
//
//  final String locale;
//
//  /// The current selected date to display inside the field
//  final DateTime selectedDate;
//
//  /// (optional) The first date that the user can select (default is 1900)
//  final DateTime firstDate;
//
//  /// (optional) The last date that the user can select (default is 2100)
//  final DateTime lastDate;
//
//  /// Let you choose the [DatePickerMode] for the date picker! (default is [DatePickerMode.day]
//  final DatePickerMode initialDatePickerMode;
//
//  /// The label to display for the field (default is 'Select date')
//  final String label;
//  final String hintText;
//
//  /// (optional) The error text that should be displayed under the field
//  final String errorText;
//
//  /// (optional) Custom [InputDecoration] for the [InputDecorator] widget
//  final InputDecoration decoration;
//
//  /// (optional) How to display the [DateTime] for the user (default is [DateFormat.yMMMD])
//  final DateFormat dateFormat;
//  final bool enabled;
//  final bool hiddenSuffixIcon;
//
//  @override
//  _FormDatePickerState createState() => _FormDatePickerState();
//}
//
//class _FormDatePickerState extends State<FormDatePicker2> {
//  DateTime __selectedDate;
//  @override
//  initState() {
//    __selectedDate = widget.selectedDate;
//    super.initState();
//  }
//
//
//  @override
//  void didUpdateWidget(FormDatePicker2 oldWidget) {
//    if (widget.selectedDate != oldWidget.selectedDate) {
//      __selectedDate = widget.selectedDate;
//    }
//    super.didUpdateWidget(oldWidget);
//  }
//
//  Future<void> _selectDate(BuildContext context) async {
//    DateTime dateTime = await showDatePicker(
//        context: context,
//        firstDate: widget.firstDate??DateTime(1900),
//        initialDate: widget.selectedDate ?? DateTime.now(),
//        lastDate: widget.lastDate??DateTime(2100),
//      locale:  _toLocale(widget.locale)
//    );
//    if (dateTime != null) {
//      if(widget.showTime) {
//        final TimeOfDay time = await showTimePicker(
//          context: context,
//          initialTime: TimeOfDay.fromDateTime(
//              widget.selectedDate ?? DateTime.now()),
//        );
//        DateTime _date = DateTimeField.combine(dateTime, time);
//        if(widget.firstDate != null && _date.compareTo(widget.firstDate) != 1){
//          _date = widget.firstDate;
//        }
//        if(widget.lastDate != null && _date.compareTo(widget.lastDate) != -1){
//          _date = widget.firstDate;
//        }
//        if(mounted){
//          setState(() {
//            __selectedDate = _date;
//          });
//        }
//        if(widget.onDateSelected != null)widget.onDateSelected(_date);
//        if(widget.onChanged != null)widget.onChanged(date(_date,'dd/MM/yyyy HH:mm:ss'));
//      }else{
//        if(mounted){
//          if(widget.firstDate != null && dateTime.compareTo(widget.firstDate) != 1){
//            dateTime = widget.firstDate;
//          }
//          if(widget.lastDate != null && dateTime.compareTo(widget.lastDate) != -1){
//            dateTime = widget.firstDate;
//          }
//          setState(() {
//            __selectedDate = dateTime;
//          });
//          if(widget.onDateSelected != null)widget.onDateSelected(__selectedDate);
//          if(widget.onChanged != null)widget.onChanged(date(__selectedDate,'dd/MM/yyyy'));
//        }
//      }
//    }else{
////      if(widget.onDateSelected != null)widget.onDateSelected();
////      if(widget.onChanged != null)widget.onChanged(date(_date,'dd/MM/yyyy HH:mm:ss'));
//    }
//  }
//
//  Locale _toLocale([locale]) {
//    switch (locale ?? currentLanguage) {
//      case 'vi':
//        return Locale('vi', 'VN');
//      default:
//        return Locale('en', 'US');
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    String text;
//    if (__selectedDate != null)
//      text = (widget.dateFormat ?? DateFormat('dd/MM/yyyy${widget.showTime?' HH:mm':''}')).format(__selectedDate);
//    return _InputDropdown(
//      enabled: widget.enabled,
//      text: text ?? widget.label ?? widget.hintText.lang(),
//      label: text == null ? null : widget.label,
//      errorText: widget.errorText,
//      decoration: widget.decoration,
//      hiddenSuffixIcon: widget.hiddenSuffixIcon,
//      hintText: widget.hintText.lang(),
//      onPressed: () {
//        print(widget.firstDate);
//        _selectDate(context);
//      },
//    );
//  }
//}
//
//class _InputDropdown extends StatelessWidget {
//  const _InputDropdown(
//      {Key key,
//      this.label,
//      this.text,
//      this.decoration,
//      this.textStyle,
//      this.onPressed,
//      this.enabled,
//      this.hiddenSuffixIcon,
//      this.errorText,
//      this.hintText = 'Chọn'})
//      : super(key: key);
//
//  /// The label to display for the field (default is 'Select date')
//  final String label;
//  final String hintText;
//
//  /// The text that should be displayed inside the field
//  final String text;
//
//  /// (optional) The error text that should be displayed under the field
//  final String errorText;
//
//  /// (optional) Custom [InputDecoration] for the [InputDecorator] widget
//  final InputDecoration decoration;
//
//  /// TextStyle for the field
//  final TextStyle textStyle;
//
//  /// Callbacks triggered whenever the user presses on the field!
//  final VoidCallback onPressed;
//  final bool enabled;
//  final bool hiddenSuffixIcon;
//
//  @override
//  Widget build(BuildContext context) {
//    assert(text != null);
//
//    BorderRadius inkwellBorderRadius;
//
//    if (decoration?.border?.runtimeType == OutlineInputBorder) {
//      inkwellBorderRadius = BorderRadius.circular(8);
//    }
//    return InkWell(
//      borderRadius: inkwellBorderRadius,
//      onTap: (enabled) ? onPressed : null,
//      child: Container(
//        decoration: empty(enabled) ? BoxDecoration(
//          borderRadius: BorderRadius.all(Radius.circular(5)),
//          color: Colors.grey.withOpacity(0.1),
//        ) : null,
//        child: TextFormField(
//          controller: TextEditingController()..text = text ?? null,
//          enabled: false,
//          maxLines: 1,
//          decoration: !empty(decoration) ? decoration.copyWith(
//            disabledBorder: enabled?decoration.enabledBorder:decoration.disabledBorder,
//            suffixIcon: !hiddenSuffixIcon?Icon(
//              Icons.keyboard_arrow_down,
//            ):null,
//          ):
//          InputDecoration(
//              labelText: label,
//              hintText: hintText?.lang(),
//              errorText: errorText,
//              suffixIcon: !hiddenSuffixIcon?Icon(
//                Icons.keyboard_arrow_down,
//              ):null,
//              border: UnderlineInputBorder(borderSide: BorderSide()),
//              errorBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Colors.red)),
//              errorStyle: TextStyle(color: Colors.red),
//          ),
//        ),
//      ),
//    );
//  }
//}
