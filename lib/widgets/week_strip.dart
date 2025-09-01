import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selected;
  final DateTime today;
  final Color primary;
  final ValueChanged<DateTime> onSelect;

  const WeekStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.today,
    required this.primary,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final d = DateFormat('d').format(days[i]);
        final w = DateFormat('E').format(days[i]); // Mon, Tue...
        final isSelected = _isSameDay(days[i], selected);
        final isToday = _isSameDay(days[i], today);

        return GestureDetector(
          onTap: () => onSelect(days[i]),
          child: Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // broj dana u “badge” kvadratu
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.1)
                        : const Color(0xFFE9F2FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isToday ? 'Today' : w,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
