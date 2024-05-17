import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class CSVFilterDialog extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?, String?, String?) onFiltersApplied;

  const CSVFilterDialog(this.onFiltersApplied, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CSVFilterDialogState createState() => _CSVFilterDialogState();
}

class _CSVFilterDialogState extends State<CSVFilterDialog> {
  DateTime? startDate;
  DateTime? endDate;
  String? productFilter;
  String? shopFilter;
  String? categoryFilter;

  void _setDateRange(DateTime? start, DateTime? end) {
    setState(() {
      startDate = start;
      endDate = end;
    });
  }

  void _showDateRangePicker() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {},
      onConfirm: (date) {
        _setDateRange(date, date);
      },
      currentTime: startDate ?? DateTime.now(),
      locale: LocaleType.en,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtruj dane'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                _setDateRange(DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0));
              },
              child: const Text('Obecny miesiąc'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                _setDateRange(startOfWeek, startOfWeek.add(const Duration(days: 6)));
              },
              child: const Text('Obecny tydzień'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime today = DateTime.now();
                _setDateRange(today, today);
              },
              child: const Text('Dzisiaj'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                _setDateRange(now.subtract(const Duration(days: 7)), now);
              },
              child: const Text('7 dni wstecz'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                _setDateRange(now.subtract(const Duration(days: 30)), now);
              },
              child: const Text('30 dni wstecz'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                _setDateRange(DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 0));
              },
              child: const Text('Obecny rok'),
            ),
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                _setDateRange(DateTime(now.year - 1, 1, 1), DateTime(now.year, 1, 0));
              },
              child: const Text('Rok wstecz'),
            ),
            ElevatedButton(
              onPressed: () {
                _setDateRange(null, null); // No date range
              },
              child: const Text('Całość'),
            ),
            ElevatedButton(
              onPressed: _showDateRangePicker,
              child: const Text('Wybierz zakres dat na kalendarzu'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Produkt'),
              onChanged: (value) {
                setState(() {
                  productFilter = value;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Sklep'),
              onChanged: (value) {
                setState(() {
                  shopFilter = value;
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Kategoria'),
              onChanged: (value) {
                setState(() {
                  categoryFilter = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onFiltersApplied(
                startDate, endDate, productFilter, shopFilter, categoryFilter);
            Navigator.of(context).pop();
          },
          child: const Text('Filtruj'),
        ),
      ],
    );
  }
}