import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initializeDateService() async {
  await initializeDateFormatting('fr_FR', null);
}

String getFormatedTodayFR() {
  final now = DateTime.now();
  return DateFormat('EEEE d MMMM y', 'fr_FR').format(now);
}

class DateService {
  static final List<String> _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  static String formatDateTime(DateTime date) {
    return "${date.day} ${_months[date.month - 1]} ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }

  static String formatDate(DateTime date) {
    return "${date.day} ${_months[date.month - 1]} ${date.year}";
  }

  static String formatTime(DateTime date) {
    return "${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }
}
