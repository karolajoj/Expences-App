import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterOptionsList extends StatelessWidget {
  final Function(DateTime?, DateTime?, String) onSelectDateRange;
  final DateTime now;
  final List<DateTime?> selectedDates;

  const FilterOptionsList({
    super.key,
    required this.onSelectDateRange,
    required this.now,
    required this.selectedDates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Dzisiaj'),
          onTap: () {
            Navigator.pop(context);
            onSelectDateRange(now, now, 'Dzisiaj');
          },
        ),
        ListTile(
          title: const Text('Obecny tydzień'),
          onTap: () {
            Navigator.pop(context);
            DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            onSelectDateRange(startOfWeek, startOfWeek.add(const Duration(days: 6)), 'Obecny tydzień');
          },
        ),
        ListTile(
          title: const Text('Obecny miesiąc'),
          onTap: () {
            Navigator.pop(context);
            onSelectDateRange(DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0), 'Obecny miesiąc');
          },
        ),
        ListTile(
          title: const Text('7 dni wstecz'),
          onTap: () {
            Navigator.pop(context);
            onSelectDateRange(now.subtract(const Duration(days: 7)), now, '7 dni wstecz');
          },
        ),
        ListTile(
          title: const Text('30 dni wstecz'),
          onTap: () {
            Navigator.pop(context);
            onSelectDateRange(now.subtract(const Duration(days: 30)), now, '30 dni wstecz');
          },
        ),
        ListTile(
          title: const Text('Obecny rok'),
          onTap: () {
            Navigator.pop(context);
            onSelectDateRange(DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 0), 'Obecny rok');
          },
        ),
        ListTile(
          title: const Text('Rok wstecz'),
          onTap: () {
            Navigator.pop(context);
            DateTime now = DateTime.now();
            DateTime oneYearAgo = now.subtract(const Duration(days: 365));
            onSelectDateRange(oneYearAgo, now, 'Rok wstecz');
          },
        ),
        ListTile(
          title: const Text('Całość'),
          onTap: () {
            Navigator.pop(context);
            onSelectDateRange(null, null, "Całość");
          },
        ),
        ListTile(
          title: const Text('Zakres niestandardowy'),
          onTap: () async {
            Navigator.pop(context);
            final List<DateTime?>? pickedDates = await showCalendarDatePicker2Dialog(
              context: context,
              config: CalendarDatePicker2WithActionButtonsConfig(
                calendarType: CalendarDatePicker2Type.range,
                firstDayOfWeek: 1,
              ),
              dialogSize: const Size(325, 400),
              value: selectedDates,
            );
            DateFormat dateFormat = DateFormat('dd.MM.yyyy');
            if (pickedDates != null && pickedDates.isNotEmpty) {
              onSelectDateRange(pickedDates.first, pickedDates.last, '${dateFormat.format(pickedDates.first!)} - ${dateFormat.format(pickedDates.last!)}');
            }
          },
        ),
      ],
    );
  }
}