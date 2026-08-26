import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({
    super.key,
    this.availableDates = const [],
    this.unavailableDates = const [],
    this.morningLabel = 'Morning',
    this.afternoonLabel = 'Afternoon',
    this.eveningLabel = 'Evening',
    this.onSlotSelected,
    this.initialMonth,
  });

  final List<DateTime> availableDates;
  final List<DateTime> unavailableDates;
  final String morningLabel;
  final String afternoonLabel;
  final String eveningLabel;
  final ValueChanged<AvailabilitySlot>? onSlotSelected;
  final DateTime? initialMonth;

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _month;
  DateTime? _selected;
  final _selectedSlots = <SlotKind>{};

  @override
  void initState() {
    super.initState();
    final init = widget.initialMonth ?? DateTime.now();
    _month = DateTime(init.year, init.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = _buildGrid();
    final names = _weekdayNames();
    final availableSet = _toDaySet(widget.availableDates);
    final unavailableSet = _toDaySet(widget.unavailableDates);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1, 1)),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
              ),
              Expanded(
                child: Text(
                  _monthTitle(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(
                    () => _month = DateTime(_month.year, _month.month + 1, 1)),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                for (final n in names)
                  Expanded(
                    child: Center(
                      child: Text(
                        n,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final d = days[index];
              if (d == null) return const SizedBox.shrink();
              final key = DateTime(d.year, d.month, d.day);
              final isUnavailable = unavailableSet.contains(key);
              final isAvailable =
                  widget.availableDates.isEmpty || availableSet.contains(key);
              final past = d.isBefore(DateTime(DateTime.now().year,
                  DateTime.now().month, DateTime.now().day));
              final selected = _selected != null &&
                  DateTime(_selected!.year, _selected!.month, _selected!.day) ==
                      key;
              final enabled = !isUnavailable && !past;
              final highlight = selected && enabled;
              final bg = !enabled
                  ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : highlight
                      ? scheme.primary
                      : isAvailable
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : scheme.surface;
              final fg = !enabled
                  ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                  : highlight
                      ? Colors.white
                      : isAvailable
                          ? const Color(0xFF047857)
                          : scheme.onSurface;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: enabled
                      ? () {
                          setState(() {
                            _selected = d;
                            _selectedSlots.clear();
                          });
                          if (widget.onSlotSelected != null &&
                              _selectedSlots.isNotEmpty) {
                            for (final s in _selectedSlots) {
                              widget.onSlotSelected!
                                  .call(AvailabilitySlot(date: d, kind: s));
                            }
                          }
                        }
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: highlight
                            ? scheme.primary
                            : scheme.outlineVariant
                                .withValues(alpha: enabled ? 0.35 : 0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${d.day}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: fg,
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_selected != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: scheme.primary.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_available_rounded,
                          color: scheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Slots for ${_selected!.day}/${_selected!.month}/${_selected!.year}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: scheme.onSurface,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SlotChip(
                        label: widget.morningLabel,
                        selected: _selectedSlots.contains(SlotKind.morning),
                        onToggle: () => _toggle(SlotKind.morning),
                        accent: const Color(0xFFF59E0B),
                        icon: Icons.wb_twilight_rounded,
                      ),
                      _SlotChip(
                        label: widget.afternoonLabel,
                        selected: _selectedSlots.contains(SlotKind.afternoon),
                        onToggle: () => _toggle(SlotKind.afternoon),
                        accent: const Color(0xFF2563EB),
                        icon: Icons.wb_sunny_rounded,
                      ),
                      _SlotChip(
                        label: widget.eveningLabel,
                        selected: _selectedSlots.contains(SlotKind.evening),
                        onToggle: () => _toggle(SlotKind.evening),
                        accent: const Color(0xFF7C3AED),
                        icon: Icons.nightlight_round,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggle(SlotKind k) {
    setState(() {
      if (_selectedSlots.contains(k)) {
        _selectedSlots.remove(k);
      } else {
        _selectedSlots.add(k);
      }
    });
    if (widget.onSlotSelected != null && _selected != null) {
      widget.onSlotSelected!.call(AvailabilitySlot(date: _selected!, kind: k));
    }
  }

  String _monthTitle() {
    final fmt = DateFormat.MMMM();
    final m = fmt.format(DateTime(_month.year, _month.month, 1));
    return '$m ${_month.year}';
  }

  List<String> _weekdayNames() {
    final l = MaterialLocalizations.of(context).narrowWeekdays;
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    return List.generate(7, (i) => l[(first + i) % 7]);
  }

  List<DateTime?> _buildGrid() {
    final first = DateTime(_month.year, _month.month, 1);
    final fdw = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final firstWeekday = (first.weekday - 1 - fdw + 7) % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final result = <DateTime?>[];
    for (var i = 0; i < firstWeekday; i++) {
      result.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      result.add(DateTime(_month.year, _month.month, d));
    }
    while (result.length % 7 != 0) {
      result.add(null);
    }
    return result;
  }

  Set<DateTime> _toDaySet(List<DateTime> dates) {
    final s = <DateTime>{};
    for (final d in dates) {
      s.add(DateTime(d.year, d.month, d.day));
    }
    return s;
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onToggle,
    required this.accent,
    required this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onToggle;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? accent : Colors.white;
    final fg = selected ? Colors.white : scheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? accent
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: fg,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SlotKind { morning, afternoon, evening }

class AvailabilitySlot {
  const AvailabilitySlot({
    required this.date,
    required this.kind,
  });
  final DateTime date;
  final SlotKind kind;
}
