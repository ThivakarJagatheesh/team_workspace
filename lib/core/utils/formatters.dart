import 'package:intl/intl.dart';

/// Shared date formatting so every screen renders dates consistently.
class Formatters {
  Formatters._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');

  static String date(DateTime d) => _date.format(d);

  /// Human "due" hint: Overdue / Today / Tomorrow / dd MMM yyyy.
  static String due(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff < 0) return 'Overdue · ${_date.format(d)}';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    return 'Due ${_date.format(d)}';
  }
}
