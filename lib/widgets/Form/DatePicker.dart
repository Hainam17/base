import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vhv_basic/extension/string_extension.dart';
import 'package:vhv_basic/helper/system.dart';

class FormDatePicker extends StatefulWidget {
  FormDatePicker({
    this.onDateSelected,
    this.selectedDate,
    this.selectedTime,
    this.firstDate,
    this.lastDate,
    this.initialDatePickerMode = DatePickerMode.day,
    this.decoration,
    this.label,
    this.errorText,
    this.dateFormat,
    this.showTime = false,
    this.selectDate = false,
    this.onChanged,
    this.hintText = 'Chọn',
    this.locale,
    this.enabled: true,
    this.hiddenSuffixIcon: false,
    this.cancel,
    this.onlyTime = false,
    Key? key
  }):super(key:key);

  /// Callback for whenever the user selects a [DateTime]
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<String>? onChanged;
  final Function? cancel;
  final bool showTime;
  final bool selectDate;

  final String? locale;

  /// The current selected date to display inside the field
  final DateTime? selectedDate;
  final String? selectedTime;

  /// (optional) The first date that the user can select (default is 1900)
  final DateTime? firstDate;

  /// (optional) The last date that the user can select (default is 2100)
  final DateTime? lastDate;

  /// Let you choose the [DatePickerMode] for the date picker! (default is [DatePickerMode.day]
  final DatePickerMode? initialDatePickerMode;

  /// The label to display for the field (default is 'Select date')
  final String? label;
  final String? hintText;

  /// (optional) The error text that should be displayed under the field
  final String? errorText;

  /// (optional) Custom [InputDecoration] for the [InputDecorator] widget
  final InputDecoration? decoration;

  /// (optional) How to display the [DateTime] for the user (default is [DateFormat.yMMMD])
  final DateFormat? dateFormat;
  final bool enabled;
  final bool hiddenSuffixIcon;
  final bool onlyTime;


  @override
  _FormDatePickerState createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<FormDatePicker> {
  DateTime? __selectedDate;
  DateTime? dateTime;

  @override
  initState() {
    __selectedDate = widget.selectedDate;
    if(widget.onlyTime && widget.selectedTime != null){
      __selectedDate = ('${date(time())} '+ widget.selectedTime.toString()).toDateTime();
    }
    super.initState();
  }


  @override
  void didUpdateWidget(FormDatePicker oldWidget) {

    if (widget.selectedDate != oldWidget.selectedDate) {
      __selectedDate = widget.selectedDate;
    }
    if(widget.onlyTime && widget.selectedTime != null){
      if (widget.selectedTime != oldWidget.selectedTime) {
        __selectedDate = ('${date(time())} ' + widget.selectedTime.toString())
            .toDateTime();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Shows a dialog asking the user to pick a date !
  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if(__selectedDate != null && widget.firstDate != null && __selectedDate!.compareTo(widget.firstDate!) != 1){
      __selectedDate = widget.firstDate;
      if(mounted)setState(() {

      });
    }
    if(__selectedDate != null && widget.lastDate != null && __selectedDate!.compareTo(widget.lastDate!) != -1){
      __selectedDate = widget.lastDate;
      if(mounted)setState(() {

      });
    }
    BottomPicker.date(
      title: 'Chọn ngày'.lang(),
      dismissable: true,
      initialDateTime: __selectedDate ?? widget.lastDate ?? DateTime.now(),
      minDateTime: widget.firstDate ?? DateTime(1900, 1, 1),
      maxDateTime: widget.lastDate ??DateTime(2200, 12, 31),
      onChange: (val){
        dateTime = val;
      },
      onClose: (){
      },
      onSubmit: (index) {
        if(dateTime == null)dateTime = __selectedDate ?? widget.lastDate ??
            DateTime.now();
        if(dateTime is DateTime) {
          if(widget.firstDate != null && dateTime!.compareTo(widget.firstDate!) != 1){
            dateTime = widget.firstDate;
          }
          if(widget.lastDate != null && dateTime!.compareTo(widget.lastDate!) != -1){
            dateTime = widget.lastDate;

          }
          if (widget.showTime) {
            Future.delayed(Duration(milliseconds: 100), () {
              _buildTime(context);
            });
          }else{
            if(mounted)setState(() {
              __selectedDate = dateTime;
            });
            if (widget.onDateSelected != null) widget.onDateSelected!(__selectedDate!);
            if (widget.onChanged != null) widget.onChanged!(
                (widget.dateFormat ?? DateFormat('dd/MM/yyyy')).format(__selectedDate!));
          }
        }
      },
    ).show(context);
  }

  _buildTime(BuildContext context) {
    return BottomPicker.time(
        title: 'Chọn giờ'.lang(),
        initialDateTime: dateTime ?? __selectedDate ?? widget.lastDate ??
            DateTime.now(),
        minDateTime: widget.firstDate ?? DateTime(2018, 3, 5),
        maxDateTime: widget.lastDate ?? DateTime(2200, 6, 7),
        onChange: (val){
          dateTime = val;
        },
        onSubmit: (index) {
          if(dateTime == null)dateTime = __selectedDate ?? widget.lastDate ??
              DateTime.now();
          if(dateTime is DateTime) {
            if (widget.firstDate != null &&
                dateTime!.compareTo(widget.firstDate!) != 1) {
              dateTime = widget.firstDate;
            }
            if (widget.lastDate != null &&
                dateTime!.compareTo(widget.lastDate!) != -1) {
              dateTime = widget.lastDate;
            }
            if(mounted)setState(() {
              __selectedDate = dateTime;
            });
            if (widget.onDateSelected != null) widget
                .onDateSelected!(__selectedDate!);
            if (widget.onChanged != null) widget.onChanged!(
                (widget.dateFormat ?? DateFormat(widget.onlyTime?'HH:mm':'dd/MM/yyyy${widget.showTime?' HH:mm':''}')).format(__selectedDate!));
          }
        },
        onClose: () {
        },
        use24hFormat: true)
        .show(context);
  }

  @override
  Widget build(BuildContext context) {
    String? text;
    if (__selectedDate != null)
      text = (widget.dateFormat ?? DateFormat(widget.onlyTime?'HH:mm':'dd/MM/yyyy${widget.showTime?' HH:mm':''}')).format(__selectedDate!);
    return _InputDropdown(
      enabled: widget.enabled,
      text: text ?? widget.label ?? widget.hintText!.lang(),
      label: (text == null ? null : widget.label)??'',
      errorText: (widget.errorText != null) ? widget.errorText : null,
      decoration: (widget.decoration != null) ? widget.decoration : null,
      hiddenSuffixIcon: widget.hiddenSuffixIcon,
      hintText: widget.hintText!.lang(),
      onPressed: () {
        !widget.onlyTime ? _selectDate(context) : _buildTime(context);
      },
    );
  }
}

///
/// [_InputDropdown]
///
/// Shows a field with a dropdown arrow !
/// It does not show any popup menu, it'll just trigger onPressed whenever the
/// user does click on it !
class _InputDropdown extends StatelessWidget {
  const _InputDropdown(
      {Key? key,
        this.label,
        this.text,
        this.decoration,
        this.textStyle,
        this.onPressed,
        this.enabled = true,
        this.hiddenSuffixIcon = false,
        this.errorText,
        this.hintText = 'Chọn'})
      : super(key: key);

  /// The label to display for the field (default is 'Select date')
  final String? label;
  final String? hintText;

  /// The text that should be displayed inside the field
  final String? text;

  /// (optional) The error text that should be displayed under the field
  final String? errorText;

  /// (optional) Custom [InputDecoration] for the [InputDecorator] widget
  final InputDecoration? decoration;

  /// TextStyle for the field
  final TextStyle? textStyle;

  /// Callbacks triggered whenever the user presses on the field!
  final VoidCallback? onPressed;
  final bool enabled;
  final bool hiddenSuffixIcon;

  @override
  Widget build(BuildContext context) {
    assert(text != null);

    BorderRadius? inkwellBorderRadius;

    if (decoration?.border?.runtimeType == OutlineInputBorder) {
      inkwellBorderRadius = BorderRadius.circular(8);
    }
    return InkWell(
      borderRadius: inkwellBorderRadius,
      onTap: (enabled) ? onPressed : null,
      child: Container(
        decoration: empty(enabled) ? BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.grey.withOpacity(0.1),
        ) : null,
        child: TextFormField(
          controller: TextEditingController()..text = text ?? '',
          enabled: false,
          maxLines: 1,
          decoration: !empty(decoration) ? decoration!.copyWith(
            disabledBorder: enabled?decoration!.enabledBorder:decoration!.disabledBorder,
            suffixIcon: !hiddenSuffixIcon?Icon(
              Icons.keyboard_arrow_down,
            ):null,
          ):
          InputDecoration(
            labelText: label,
            hintText: hintText?.lang(),
            errorText: errorText,
            suffixIcon: !hiddenSuffixIcon?Icon(
              Icons.keyboard_arrow_down,
            ):null,
            border: UnderlineInputBorder(borderSide: BorderSide()),
            errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
            errorStyle: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
