import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/week_strip.dart';
import '../widgets/slot_grid.dart';

class SubmitTerminScreen extends StatefulWidget {
  const SubmitTerminScreen({super.key});

  @override
  State<SubmitTerminScreen> createState() => _SubmitTerminScreenState();
}

class _SubmitTerminScreenState extends State<SubmitTerminScreen> {
  // ---- Konfig radnog vremena / koraka ----
  static const int _openingHour = 9;   // 09:00
  static const int _closingHour = 17;  // 17:00 (ne uključuje 17:00)
  static const Duration _slotStep = Duration(minutes: 20);

  // ---- Mock zauzeća (zamijeni backend-om) ----
  final Map<String, Set<String>> _bookedByDay = {
    _fmtDate(DateTime.now()): {'10:30', '11:10'},
    _fmtDate(DateTime.now().add(const Duration(days: 1))): {'13:30'},
  };

  // ---- State ----
  final DateTime _today = _stripTime(DateTime.now());
  late DateTime _selectedDate = _today;
  TimeOfDay? _selectedTime;

  // ---- Helperi datuma/vremena ----
  static String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static String _fmtHm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _monday {
    final wd = _today.weekday; // Mon=1..Sun=7
    return _today.subtract(Duration(days: wd - 1));
  }

  List<DateTime> get _currentWeekDays =>
      List.generate(7, (i) => _monday.add(Duration(days: i)));

  List<TimeOfDay> _generateSlotsFor(DateTime day) {
    final List<TimeOfDay> out = [];
    var t = const TimeOfDay(hour: _openingHour, minute: 0);
    while (_toMinutes(t) < _closingHour * 60) {
      out.add(t);
      t = _add(t, _slotStep);
    }
    return out;
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _add(TimeOfDay t, Duration d) {
    final total = _toMinutes(t) + d.inMinutes;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFE9F2FA);
    final primary = const Color(0xFF2458E6);

    final slots = _generateSlotsFor(_selectedDate);
    final bookedSet = _bookedByDay[_fmtDate(_selectedDate)] ?? const <String>{};

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Appointment',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mjesec
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              DateFormat.MMM().format(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          // TRENUTNA SEDMICA (inline)
          SizedBox(
            height: 88,
            child: WeekStrip(
              days: _currentWeekDays,
              selected: _selectedDate,
              today: _today,
              primary: primary,
              onSelect: (d) {
                setState(() {
                  _selectedDate = _stripTime(d);
                  _selectedTime = null; // reset slot selekcije
                });
              },
            ),
          ),

          // Slots naslov
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Slots',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),

          // GRID SLOTOVA
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SlotGrid(
                slots: slots,
                bookedHmSet: bookedSet,
                selected: _selectedTime,
                primary: primary,
                onSelect: (t) => setState(() => _selectedTime = t),
              ),
            ),
          ),

          // POTVRDA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_selectedTime == null)
                    ? null
                    : () {
                  final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                  final timeStr = _fmtHm(_selectedTime!);
                  // TODO: backend poziv (dateStr, timeStr)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rezervisan termin: $dateStr u $timeStr')),
                  );
                },
                child: const Text('Confirm  Appointment'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
