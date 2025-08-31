import 'package:flutter/material.dart';

class SubmitTerminScreen extends StatefulWidget {
  const SubmitTerminScreen({super.key});

  @override
  State<SubmitTerminScreen> createState() => _SubmitTerminScreenState();
}

class _SubmitTerminScreenState extends State<SubmitTerminScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Rezerviši termin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Kalendar (od danas do godinu unaprijed)
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Biranje vremena
            Card(
              color: Colors.grey[900],
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.white70),
                title: Text(
                  _selectedTime == null
                      ? 'Odaberi vrijeme'
                      : 'Vrijeme: ${_selectedTime!.format(context)}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _pickTime,
                  child: const Text('Izaberi'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Potvrda (placeholder logika)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  if (_selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Odaberi vrijeme')),
                    );
                    return;
                  }
                  // TODO: ovdje će ići slanje termina na backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Termin: ${_selectedDate.toLocal().toString().split(' ').first} u ${_selectedTime!.format(context)} (placeholder)',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Potvrdi termin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
