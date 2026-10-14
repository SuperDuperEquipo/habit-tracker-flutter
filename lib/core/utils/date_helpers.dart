import 'package:intl/intl.dart';

final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd', 'en_US');
final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String dateKey(DateTime value) => _dateKeyFormat.format(value);

DateTime? parseDateKey(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed == null ? null : dateOnly(parsed);
}

String formatReminderTime(int hour, int minute) {
  final hh = hour.toString().padLeft(2, '0');
  final mm = minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

({int hour, int minute})? parseReminderTime(String? value) {
  if (value == null) return null;
  final match = _timePattern.firstMatch(value);
  if (match == null) return null;
  return (hour: int.parse(match.group(1)!), minute: int.parse(match.group(2)!));
}
