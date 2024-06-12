import '../Local Data/expenses_list_element.dart';
import 'package:expenses_app_project/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

class CSVLoader {
  final Function(List<ExpensesListElementModel>) onDataLoaded;

  CSVLoader(this.onDataLoaded);

  Future<void> importCSV(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

    if (result != null) {
      final input = File(result.files.single.path!).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(fieldDelimiter: ";"))
          .toList();

      fields.removeAt(0); // Remove header

      List<ExpensesListElementModel> csvData = fields.map((row) {
        return ExpensesListElementModel(
          data: DateFormat('dd.MM.yyyy').parse(row[0]),
          sklep: row[1],
          kategoria: row[2],
          produkt: row[3] == "" ? "Brak danych" : row[3],
          ilosc: row[4] ?? 0,
          cena: row[5] == "" ? 0.0 : double.tryParse(row[5].replaceAll(' zł', '').replaceAll(',', '.').replaceAll(' ', '')) ?? 0.0,
          miara: row[6] == "" ? null : row[6],
          iloscWOpakowaniu: row[7] == "" ? null : row[7] ?? 0,
          zwrot: (row[8].trim() == "Tak" || row[8].trim() == "-") ? true : false,
          kosztDostawy: row[9] == "" ? null : double.tryParse(row[9].replaceAll(' zł', '').replaceAll(',', '.').replaceAll(' ', '')) ?? 0.0,
          link: row[10].trim(),
          komentarz: row[11].trim(),
        );
      }).toList();

      bool? confirm = await _showConfirmationDialog(csvData.length);

      if (confirm == true) {
        await _saveData(csvData, scaffoldMessengerKey);
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Import anulowany')));
      }
    }
  }

  Future<bool?> _showConfirmationDialog(int dataCount) {
    return showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potwierdzenie Importu'),
          content: Text('Czy chcesz dodać $dataCount nowych wydatków?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Nie'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Tak'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveData(List<ExpensesListElementModel> csvData, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {
    try {
      var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
      await box.addAll(csvData);

      onDataLoaded(csvData);
      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Dane zostały zaimportowane')));
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wystąpił błąd podczas przetwarzania pliku CSV: $e')));
    }
  }
}