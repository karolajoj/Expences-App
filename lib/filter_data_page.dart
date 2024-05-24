import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class FilterDataPage extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?, String?, String?) onFiltersApplied;

  const FilterDataPage(this.onFiltersApplied, {super.key});

  @override
  FilterDataPageState createState() => FilterDataPageState();
}

class FilterDataPageState extends State<FilterDataPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtruj dane'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Opcje filtrowania'),
              trailing: const Icon(Icons.expand_more),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Obecny miesiąc'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime now = DateTime.now();
                            _setDateRange(DateTime(now.year, now.month, 1),
                                DateTime(now.year, now.month + 1, 0));
                          },
                        ),
                        ListTile(
                          title: const Text('Obecny tydzień'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime now = DateTime.now();
                            DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                            _setDateRange(startOfWeek, startOfWeek.add(const Duration(days: 6)));
                          },
                        ),
                        ListTile(
                          title: const Text('Dzisiaj'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime today = DateTime.now();
                            _setDateRange(today, today);
                          },
                        ),
                        ListTile(
                          title: const Text('7 dni wstecz'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime now = DateTime.now();
                            _setDateRange(now.subtract(const Duration(days: 7)), now);
                          },
                        ),
                        ListTile(
                          title: const Text('30 dni wstecz'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime now = DateTime.now();
                            _setDateRange(now.subtract(const Duration(days: 30)), now);
                          },
                        ),
                        ListTile(
                          title: const Text('Obecny rok'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime now = DateTime.now();
                            _setDateRange(
                                DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 0));
                          },
                        ),
                        ListTile(
                          title: const Text('Rok wstecz'),
                          onTap: () {
                            Navigator.pop(context);
                            DateTime now = DateTime.now();
                            _setDateRange(
                                DateTime(now.year - 1, 1, 1), DateTime(now.year, 1, 0));
                          },
                        ),
                        ListTile(
                          title: const Text('Całość'),
                          onTap: () {
                            Navigator.pop(context);
                            _setDateRange(null, null); // No date range
                          },
                        ),
                      ],
                    );
                  },
                );
              },
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
            ElevatedButton(
              onPressed: _showDateRangePicker,
              child: const Text('Wybierz zakres dat na kalendarzu'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onFiltersApplied(
                    startDate, endDate, productFilter, shopFilter, categoryFilter);
                Navigator.of(context).pop();
              },
              child: const Text('Filtruj'),
            ),
          ],
        ),
      ),
    );
  }
}