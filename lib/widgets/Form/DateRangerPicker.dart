import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vhv_basic/import.dart';

class FormDateRangerPicker extends StatefulWidget {
  final String? value;
  final String? errorText;
  final String? labelText;
  final String? description;
  final ValueChanged? onChanged;
  final InputDecoration? decoration;
  final bool enabled;
  final bool autoRemove;
  final Widget? trailing;
  final PickerDateRange? initialValue;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateFormat? dateFormat;
  final TextStyle? textStyle;
  final Function(DateTime start, DateTime end)? onSelectionChanged;
  final Color? rangeSelectionColor, bgCancel, bgConfirm;

  const FormDateRangerPicker(
      {Key? key, this.value, this.errorText, this.labelText, this.description,
        this.onChanged, this.decoration, this.enabled = true, this.trailing, this.initialValue, this.minDate,
        this.maxDate, this.rangeSelectionColor, this.bgCancel, this.dateFormat, this.bgConfirm, this.textStyle,
        this.onSelectionChanged, this.autoRemove = true}) : super(key: key);

  @override
  _FormDateRangerPickerState createState() => _FormDateRangerPickerState();
}

class _FormDateRangerPickerState extends State<FormDateRangerPicker> {
  TextEditingController? _textEditingController;
  String value = '';
  onChanged(dynamic value){
    this.value = value;
    _textEditingController!.text = !empty(value)?value:(widget.description??'');
    if(widget.onChanged != null)widget.onChanged!(value);
  }


  @override
  void initState() {
    value = widget.value??'';
    _textEditingController = TextEditingController()..text = widget.value??'';
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FormDateRangerPicker oldWidget) {
    _textEditingController!.text = widget.value??'';
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.enabled ? () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        await showBottomMenu(
          title: 'Chọn ngày'.lang(),
          actionLeft: IconButton(

              onPressed: () => appNavigator.pop(),
              icon: Icon(Icons.close, color: Theme
                  .of(context)
                  .floatingActionButtonTheme
                  .backgroundColor)
          ),
          actionRight: IconButton(
              onPressed: (){
                onChanged('');
                appNavigator.pop();
              },
              icon: Icon(Icons.delete, color: Theme
                  .of(context).errorColor)
          ),
          child: FormDateRangerWidget(
              autoRemove: widget.autoRemove,
              onChanged: onChanged,
              minDate: widget.minDate,
              maxDate: widget.maxDate,
              rangeSelectionColor: widget.rangeSelectionColor,
              bgCancel: widget.bgCancel,
              bgConfirm: widget.bgConfirm,
              onSelectionChanged: widget.onSelectionChanged,
              value: value
          ),
        );
      } : null,
      child: Container(
        decoration: !widget.enabled ? BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.grey.withOpacity(0.1),
        ) : null,
        child: TextFormField(
          controller: _textEditingController,
          style: widget.textStyle,
          enabled: false,
          maxLines: 1,
          decoration: (widget.decoration != null) ? widget.decoration : null,

        ),
      ),
    );
  }

}

class FormDateRangerWidget extends StatefulWidget {
  final ValueChanged? onChanged;
  final Function(DateTime start, DateTime end)? onSelectionChanged;
  final controller;
  final DateTime? minDate, maxDate;
  final String? textCancel, textConfirm, tag;
  final bool autoRemove, isCheck;
  final Color? bgCancel, bgConfirm, rangeSelectionColor;
  final Widget? actionWidget;
  final DateFormat? dateFormat;
  final String? value;

  FormDateRangerWidget({this.onChanged, this.onSelectionChanged,
    this.controller,
    this.minDate,
    this.maxDate,
    this.textCancel,
    this.textConfirm,
    this.autoRemove = true,
    this.bgCancel,
    this.bgConfirm,
    this.tag,
    this.dateFormat,
    this.actionWidget,
    this.isCheck = false, this.rangeSelectionColor, this.value});

  @override
  _FormDateRangerWidgetState createState() => _FormDateRangerWidgetState();
}

class _FormDateRangerWidgetState extends State<FormDateRangerWidget> {
  var _days = <String>['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  String _date = '';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FormDateRangerController>(
        init: FormDateRangerController(
            !empty(widget.value) ? widget.value! : ''
        ),
        autoRemove: widget.autoRemove,
        builder: (controller) {
          return Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.8,
            child: Column(
              // shrinkWrap: true,
              // physics: ScrollPhysics(),
              children: [
                Container(
                  height: 20,
                  // margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _days.length,
                    itemBuilder: (context, int index) {
                      return Container(
                        width: Get.width / 7,
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        height: 5,
                        child: Text('${_days[index]}'.lang()),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SfDateRangePicker(
                            onSelectionChanged: (args) {
                              if (args.value is PickerDateRange) {
                                controller.setDate(
                                    start: (args.value as PickerDateRange)
                                        .startDate,
                                    end: (args.value as PickerDateRange)
                                        .endDate);
                              }
                              if (widget.onSelectionChanged != null) widget
                                  .onSelectionChanged!(
                                  args.value.startDate, args.value.endDate);
                              if (empty(args.value.endDate) || (args.value.startDate == args.value.endDate)) {
                                _date = '${(widget.dateFormat ??
                                    DateFormat('dd/MM/yyyy')).format(
                                    args.value.startDate)}';
                              }
                              else {
                                _date = '${(widget.dateFormat ??
                                    DateFormat('dd/MM/yyyy')).format(
                                    args.value.startDate)}' + ' - ' +
                                    '${(widget.dateFormat ??
                                        DateFormat('dd/MM/yyyy')).format(
                                        args.value.endDate)}';
                              }
                            },
                            maxDate: widget.maxDate ?? null,
                            minDate: widget.minDate ?? null,
                            initialSelectedRange: PickerDateRange(
                                controller.startDate, controller.endDate),
                            selectionMode: DateRangePickerSelectionMode.range,
                            monthFormat: 'MM /',
                            monthViewSettings: DateRangePickerMonthViewSettings(
                              dayFormat: ''),
                            enableMultiView: true,
                            navigationDirection: DateRangePickerNavigationDirection
                                .vertical,
                            viewSpacing: 10,
                            startRangeSelectionColor: Theme
                                .of(context)
                                .floatingActionButtonTheme
                                .backgroundColor,
                            todayHighlightColor: Theme
                                .of(context)
                                .floatingActionButtonTheme
                                .backgroundColor,

                            endRangeSelectionColor: Theme
                                .of(context)
                                .floatingActionButtonTheme
                                .backgroundColor,
                            selectionColor: Theme
                                .of(context)
                                .floatingActionButtonTheme
                                .backgroundColor,
                            rangeSelectionColor: widget.rangeSelectionColor ??
                                Theme
                                    .of(context)
                                    .floatingActionButtonTheme
                                    .backgroundColor!
                                    .withOpacity(0.3),
                          ),
                        ),
                        (widget.actionWidget != null) ? widget.actionWidget! :
                        ButtonRaised(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: widget.bgConfirm ?? Theme
                              .of(context)
                              .floatingActionButtonTheme
                              .backgroundColor,
                          onPressed: (){
                            if (widget.onChanged != null) widget.onChanged!(
                                _date);
                            appNavigator.pop(widget.value);
                          },
                          child: Text('${widget.textConfirm ?? 'Hoàn tất'}'.lang(),
                            style: TextStyle(
                                fontSize: 16
                            )),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class FormDateRangerController extends GetxController {
  DateTime? startDate;
  DateTime? endDate;
  final String value;

  FormDateRangerController([this.value = '']);

  @override
  void onInit() {
    if (!empty(value)) {
      var values;
      values = value.split('-');
      if (!empty(values) && values is List) {
        if (values.length == 2) {
          setDate(start: values[0].toString().toDateTime(),
              end: values[1].toString().toDateTime());
        }
        else if (values.length == 1) {
          setDate(start: values[0].toString().toDateTime(),
              end: values[0].toString().toDateTime());
        }
      }
    }
    super.onInit();
  }

  void setDate({DateTime? start, DateTime? end}) {
    startDate = start;
    endDate = end;
    update();
  }


  bool get checkIssetDate =>
      startDate != null && endDate != null ? true : false;

  void removeDate() {
    startDate = null;
    endDate = null;
    update();
  }
}

