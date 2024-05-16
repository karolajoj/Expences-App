import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtruj dane'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Data początkowa (DD.MM.YYYY)'),
              onChanged: (value) {
                setState(() {
                  startDate = DateFormat('dd.MM.yyyy').parse(value);
                });
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: 'Data końcowa (DD.MM.YYYY)'),
              onChanged: (value) {
                setState(() {
                  endDate = DateFormat('dd.MM.yyyy').parse(value);
                });
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