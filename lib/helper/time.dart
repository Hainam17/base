import 'package:timeago/timeago.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vhv_basic/import.dart';

class _ViMessagesFix implements LookupMessages {
  _ViMessagesFix([this.hasShort = true]);
  final bool hasShort;
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'vừa xong';
  @override
  String aboutAMinute(int minutes) => '1 phút${hasShort?'':' trước'}';
  @override
  String minutes(int minutes) => '$minutes phút${hasShort?'':' trước'}';
  @override
  String aboutAnHour(int minutes) => '1 giờ${hasShort?'':' trước'}';
  @override
  String hours(int hours) => '$hours giờ${hasShort?'':' trước'}';
  @override
  String aDay(int hours) => '1 ngày${hasShort?'':' trước'}';
  @override
  String days(int days) => '$days ngày${hasShort?'':' trước'}';
  @override
  String aboutAMonth(int days) => '1 tháng${hasShort?'':' trước'}';
  @override
  String months(int months) => '$months tháng${hasShort?'':' trước'}';
  @override
  String aboutAYear(int year) => '1 năm${hasShort?'':' trước'}';
  @override
  String years(int years) => '$years năm${hasShort?'':' trước'}';
  @override
  String wordSeparator() => ' ';
}

class _ViShortMessagesFix implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'vừa xong';
  @override
  String aboutAMinute(int minutes) => '1 ph';
  @override
  String minutes(int minutes) => '$minutes ph';
  @override
  String aboutAnHour(int minutes) => '~1 h';
  @override
  String hours(int hours) => '$hours h';
  @override
  String aDay(int hours) => '~1 ngày';
  @override
  String days(int days) => '$days ngày';
  @override
  String aboutAMonth(int days) => '~1 tháng';
  @override
  String months(int months) => '$months tháng';
  @override
  String aboutAYear(int year) => '~1 năm';
  @override
  String years(int years) => '$years năm';
  @override
  String wordSeparator() => ' ';
}

String timeAgo(DateTime date,
    {String? locale, DateTime? clock, bool? allowFromNow, bool hasShort = true}) {
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('dv', timeago.DvMessages());
  timeago.setLocaleMessages('dv_short', timeago.DvShortMessages());
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
  timeago.setLocaleMessages('ca', timeago.CaMessages());
  timeago.setLocaleMessages('ca_short', timeago.CaShortMessages());
  timeago.setLocaleMessages('ja', timeago.JaMessages());
  timeago.setLocaleMessages('km', timeago.KmMessages());
  timeago.setLocaleMessages('km_short', timeago.KmShortMessages());
  timeago.setLocaleMessages('id', timeago.IdMessages());
  timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  timeago.setLocaleMessages('pt_BR_short', timeago.PtBrShortMessages());
  timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  timeago.setLocaleMessages('it', timeago.ItMessages());
  timeago.setLocaleMessages('it_short', timeago.ItShortMessages());
  timeago.setLocaleMessages('fa', timeago.FaMessages());
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  timeago.setLocaleMessages('pl', timeago.PlMessages());
  timeago.setLocaleMessages('th', timeago.ThMessages());
  timeago.setLocaleMessages('th_short', timeago.ThShortMessages());
  timeago.setLocaleMessages('nb_NO', timeago.NbNoMessages());
  timeago.setLocaleMessages('nb_NO_short', timeago.NbNoShortMessages());
  timeago.setLocaleMessages('nn_NO', timeago.NnNoMessages());
  timeago.setLocaleMessages('nn_NO_short', timeago.NnNoShortMessages());
  timeago.setLocaleMessages('ku', timeago.KuMessages());
  timeago.setLocaleMessages('ku_short', timeago.KuShortMessages());
  timeago.setLocaleMessages('ar', timeago.ArMessages());
  timeago.setLocaleMessages('ar_short', timeago.ArShortMessages());
  timeago.setLocaleMessages('ko', timeago.KoMessages());
  timeago.setLocaleMessages('vi', _ViMessagesFix(hasShort));
  timeago.setLocaleMessages('vi_short', _ViShortMessagesFix());
  timeago.setLocaleMessages('ta', timeago.TaMessages());
  timeago.setLocaleMessages('ro', timeago.RoMessages());
  timeago.setLocaleMessages('ro_short', timeago.RoShortMessages());
  timeago.setLocaleMessages('sv', timeago.SvMessages());
  timeago.setLocaleMessages('sv_short', timeago.SvShortMessages());
  return timeago.format(date,
      locale: locale, clock: clock, allowFromNow: allowFromNow??false);
}

String durationToTime(Duration duration, [bool hasLabel = false]) {
  String twoDigits(int n) => (n < 10)?'0$n':'$n';
  String twoDigitHours = twoDigits(duration.inHours);
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String _label = '';
  if(duration.inHours > 0){
    if(hasLabel){
      _label = '$twoDigitHours '+'giờ'.lang(args:['$twoDigitHours'])+' $twoDigitMinutes '+'phút'.lang(args:['$twoDigitMinutes'])+' $twoDigitSeconds '+'giây'.lang(args:['$twoDigitSeconds']);
    }else if(duration.inMinutes > 0){
      _label = '$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds';
    }
  }else if(duration.inMinutes > 0){
    if(hasLabel){
      _label = '$twoDigitMinutes '+'phút'.lang(args:['$twoDigitMinutes'])+' $twoDigitSeconds '+'giây'.lang(args:['$twoDigitSeconds']);
    }else{
      _label = '$twoDigitMinutes:$twoDigitSeconds';
    }
  }else{
    if(hasLabel){
      _label = '$twoDigitSeconds '+'giây'.lang(args:['$twoDigitSeconds']);
    }else{
      _label = '$twoDigitMinutes:$twoDigitSeconds';
    }
  }
  return _label;
}
checkServerTime(int time, DateTime start) async {
  final int _start = ((start.millisecondsSinceEpoch)/1000).ceil();
  final int _now = (((new DateTime.now()).millisecondsSinceEpoch)/1000).ceil();
  final _differenceTime = (time - _now - (_now - _start));
  await Setting().put('differenceTime', _differenceTime );
}
bool isHappening(int? startTime, int? endTime){
  if((startTime??0) < time() && (endTime??0) > time()){
    return true;
  }
  return false;
}