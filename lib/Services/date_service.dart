import 'package:intl/intl.dart';

String getFormatedTodayFR() {
  final now = DateTime.now();
  return DateFormat('EEEE d MMMM y', 'fr_FR').format(now);
}
