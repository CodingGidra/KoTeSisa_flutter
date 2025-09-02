import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay parseHmOrHms(String s) {
  final parts = s.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return TimeOfDay(hour: h, minute: m);
}

String formatTimeOfDay(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String formatDate(DateTime d) =>
    DateFormat('yyyy-MM-dd').format(d);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
