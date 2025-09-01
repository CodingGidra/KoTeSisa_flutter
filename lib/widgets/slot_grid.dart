import 'package:flutter/material.dart';

class SlotGrid extends StatelessWidget {
  final List<TimeOfDay> slots;
  final Set<String> bookedHmSet; // npr. {'10:30', '11:10'}
  final TimeOfDay? selected;
  final Color primary;
  final ValueChanged<TimeOfDay> onSelect;

  const SlotGrid({
    super.key,
    required this.slots,
    required this.bookedHmSet,
    required this.selected,
    required this.primary,
    required this.onSelect,
  });

  String _fmtHm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final t in slots)
          _SlotPill(
            label: _fmtHm(t),
            disabled: bookedHmSet.contains(_fmtHm(t)),
            selected: selected != null && _fmtHm(selected!) == _fmtHm(t),
            primary: primary,
            onTap: () => onSelect(t),
          ),
      ],
    );
  }
}

class _SlotPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final Color primary;
  final VoidCallback onTap;

  const _SlotPill({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    if (disabled) {
      bg = Colors.white;
      fg = Colors.black38;
    } else if (selected) {
      bg = primary;
      fg = Colors.white;
    } else {
      bg = Colors.white;
      fg = Colors.black87;
    }

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: disabled ? Border.all(color: Colors.black12) : null,
          boxShadow: [
            if (!disabled && !selected)
              BoxShadow(
                blurRadius: 6,
                offset: const Offset(0, 2),
                color: Colors.black.withOpacity(0.05),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: fg),
        ),
      ),
    );
  }
}
