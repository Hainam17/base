import 'package:intl/intl.dart';

extension DatetimeExtension on DateTime{
  String toStr([String? format]){
    return DateFormat(format??'dd/MM/yyyy').format(this);
  }
  int toUnixStamp(){
    return (this.toUtc().millisecondsSinceEpoch/1000).ceil();
  }
}