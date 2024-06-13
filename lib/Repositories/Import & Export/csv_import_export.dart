import '../Local Data/expenses_list_element.dart';
import 'package:expenses_app_project/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

enum ExportOption { allData, filteredData }

Future<void> loadCSV(Function(void Function()) setState, List<ExpensesListElementModel> csvData, List<ExpensesListElementModel> filteredData,
  Map<String, Color> dateColorMap, VoidCallback applyDefaultFilters, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, bool keepCurrentData) async {

  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

  if (result != null) {
    final input = File(result.files.single.path!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter(fieldDelimiter: ";"))
        .toList();

    fields.removeAt(0); // Remove header

    List<ExpensesListElementModel> csvDataList = fields.map((row) {
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

    bool? confirm = await _showConfirmationDialog(csvDataList.length);

    if (confirm == true) {
      if (!keepCurrentData) {
        var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
        await box.clear();
        // Dodatkowo dane powinny być tu usuwane z Firebase
      }

      setState(() {
        if (!keepCurrentData) {
          csvData.clear();
          filteredData.clear();
          dateColorMap.clear();
        }
        csvData.addAll(csvDataList);
        filteredData.addAll(csvDataList);

        for (var row in csvData) {
          String currentDay = DateFormat('dd.MM.yyyy').format(row.data);
          if (!dateColorMap.containsKey(currentDay)) {
            Color newColor = dateColorMap.isEmpty || dateColorMap.values.last == Colors.grey[350]
                ? Colors.blue[100]!
                : Colors.grey[350]!;
            dateColorMap[currentDay] = newColor;
          }
        }

        applyDefaultFilters();
      });

      var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
      await box.addAll(csvDataList);

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Dane zostały zaimportowane')),
      );
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Import anulowany')),
      );
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

Future<void> exportCSV(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, List<ExpensesListElementModel> exportData) async {
  
  if (exportData.isEmpty) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do eksportu')));
    return;
  }

  List<List<dynamic>> rows = [["Data", "Sklep", "Kategoria", "Produkt", "Ilość", "Cena", "Miara", "Ilość w opakowaniu", "Zwrot", "Koszt Dostawy", "Link", "Komentarz"]];

  for (var element in exportData) {
    List<dynamic> row = [
      DateFormat('dd.MM.yyyy').format(element.data),
      element.sklep,
      element.kategoria,
      element.produkt,
      element.ilosc,
      element.cena.toString().replaceAll(".", ","),
      element.miara ?? "",
      element.iloscWOpakowaniu ?? "",
      element.zwrot ? "Tak" : "",
      element.kosztDostawy?.toString().replaceAll(".", ",") ?? "",
      element.link,
      element.komentarz
    ];
    rows.add(row);
  }

  String csvDataString = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

  final directory = await FilePicker.platform.getDirectoryPath();
  String date = DateFormat('dd.MM.yyyy').format(DateTime.now());
  if (directory != null) {
    final path = "$directory/expenses_data-$date.csv";
    final file = File(path);

    try {
      await file.writeAsString(csvDataString, encoding: utf8);  
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wyeksportowano plik CSV do: $path')));
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wystąpił błąd podczas eksportu danych: $e')));  
    }
  } else {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Nie wybrano ścieżki')));
  }
}