import 'package:timeago/timeago.dart' as timeago;

class DateMessagesPl extends timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'za';
  @override
  String suffixAgo() => 'temu';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'chwilę ';
  @override
  String aboutAMinute(int minutes) => 'około minuty';
  @override
  String minutes(int minutes) => _pluralize(minutes, 'minutę', 'minuty', 'minut');
  @override
  String aboutAnHour(int minutes) => 'około godziny';
  @override
  String hours(int hours) => _pluralize(hours, 'godzinę', 'godziny', 'godzin');
  @override
  String aDay(int hours) => 'dzień';
  @override
  String days(int days) => _pluralize(days, 'dzień', 'dni', 'dni');
  @override
  String aboutAMonth(int days) => 'około miesiąca';
  @override
  String months(int months) => _pluralize(months, 'miesiąc', 'miesiące', 'miesięcy');
  @override
  String aboutAYear(int year) => 'około roku';
  @override
  String years(int years) => _pluralize(years, 'rok', 'lata', 'lat');
  @override
  String wordSeparator() => ' ';

  String _pluralize(int number, String form1, String form2, String form3) {
    if (number == 1) {
      return '$number $form1';
    } else if (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20)) {
      return '$number $form2';
    } else {
      return '$number $form3';
    }
  }

  static void registerLocale() {
    timeago.setLocaleMessages('pl', DateMessagesPl());
  }
}
