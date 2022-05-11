import 'package:flutter/material.dart';
import 'package:vhv_basic/global.dart';
import 'package:vhv_basic/helper.dart';
import 'package:vhv_basic/widgets/Button/Base.dart';
import 'package:rxdart/rxdart.dart';

class TimePicker extends StatefulWidget {
  final Function(String)? onChanged;
  final String? value;

  TimePicker({this.onChanged, this.value});

  @override
  TimePickerState createState() => TimePickerState();
}

class TimePickerState extends State<TimePicker> {
  int _hour = 24;
  int _min = 60;
  late List<String> _time;
  late ScrollController _hourController;
  late ScrollController _minController;

  late PublishSubject<double> _hourSubject;
  late PublishSubject<double> _minSubject;

  int getValue(int index){
    return parseInt(_time.elementAt(index));
  }
  String getText(int index){
    return (index < 10)?'0$index':'$index';
  }
  setValue(int index, int val){
    _time[index] = (val < 10)?'0$val':'$val';
    if(mounted)setState(() {});
  }
  @override
  void dispose() {
    _hourController.dispose();
    _minController.dispose();
    _hourSubject.close();
    _minSubject.close();
    super.dispose();
  }

  @override
  void initState() {

    _time = ['00','00'];
    if(!empty(widget.value)){
      final _list = widget.value!.split(':');
      if(_list.length == 2){
        _time = [getText(parseInt(_list[0])),getText(parseInt(_list[1]))];
      }
    }
    _hourController = ScrollController(initialScrollOffset: (parseDouble(_time[0]) * 30))..addListener(_hourChange);
    _minController = ScrollController(initialScrollOffset: (parseDouble(_time[1]) * 30))..addListener(_minChange);
    _hourSubject = new PublishSubject()..debounceTime(Duration(milliseconds: 200)).listen((val) {
      _hourController.animateTo(val * 30, duration: Duration(milliseconds: 200),
          curve: Curves.ease);
    });
    _minSubject = new PublishSubject()..debounceTime(Duration(milliseconds: 200)).listen((val) {
      _minController.animateTo(val * 30, duration: Duration(milliseconds: 200),
          curve: Curves.ease);
    });
    super.initState();
  }


  _hourChange(){
    setValue(0, (_hourController.offset/30).round());
    _hourSubject.sink.add(parseDouble((_hourController.offset/30).round()));
  }
  _minChange(){
    setValue(1, (_minController.offset/30).round());
    _minSubject.sink.add(parseDouble((_minController.offset/30).round()));
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _hourController,
                    itemExtent: 30,
                    useMagnifier: false,
                    squeeze: 1,
                    diameterRatio: 1,
                    overAndUnderCenterOpacity: 0.8,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) => Builder(
                        builder: (_){
                          final bool _isActive = getValue(0) == index;
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                    _isActive
                                        ? Theme.of(context).toggleableActiveColor
                                        : Colors.transparent)
                              // color: valInt == int.tryParse(e.key) ? Colors.red : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                '${getText(index)} giờ',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color:
                                    _isActive
                                        ? Theme.of(context).toggleableActiveColor
                                        : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      childCount: _hour,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _minController,
                    itemExtent: 30,
                    useMagnifier: false,
                    overAndUnderCenterOpacity: 0.8,
                    squeeze: 1,
                    diameterRatio: 1,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) => Builder(
                        builder: (_){
                          final bool _isActive = getValue(1) == index;
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                    _isActive
                                        ? Theme.of(context).toggleableActiveColor
                                        : Colors.transparent)
                              // color: valInt == int.tryParse(e.key) ? Colors.red : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Center(
                              child: Text(
                                '${getText(index)} phút',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color:
                                    _isActive
                                        ? Theme.of(context).toggleableActiveColor
                                        : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      childCount: _min,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ButtonBase(
              onPressed: () {
                if (widget.onChanged != null) {
                  widget.onChanged!(_time.join(':'));
                }
                if (appNavigator.isBottomSheetOpen) {
                  appNavigator.pop();
                }
              },
              child: Text(lang('Lưu')),
            ),
          ),
        ],
      ),
    );
  }
}
