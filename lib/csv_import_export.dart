import 'package:expenses_app_project/csv_loader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'expenses_list_element.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

enum ExportOption { allData, filteredData }

void loadCSV(BuildContext context, Function(void Function()) setState, List<ExpensesListElementModel> csvData, List<ExpensesListElementModel> filteredData,
  Map<String, Color> dateColorMap, VoidCallback applyDefaultFilters, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {

  CSVLoader((data) {
    setState(() {
      csvData.clear();
      csvData.addAll(data);
      filteredData.clear();
      filteredData.addAll(data);
      dateColorMap.clear();

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

  }).importCSV(context, scaffoldMessengerKey);
}

Future<void> exportCSV(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, List<ExpensesListElementModel> exportData) async {
  
  if (exportData.isEmpty) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do eksportu')));
    return;
  }

  // ExportOption? selectedOption = await showDialog<ExportOption>(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return ExportOptionDialog(
  //       onOptionSelected: (option) => Navigator.of(context).pop(option),
  //     );
  //   },
  // );

  // if (selectedOption == null) {return;}

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

// class ExportOptionDialog extends StatelessWidget {
//   final void Function(ExportOption) onOptionSelected;

//   const ExportOptionDialog({super.key, required this.onOptionSelected});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Wybierz dane do eksportu'),
//       content: const Text('Chcesz eksportować wszystkie dane czy tylko przefiltrowane?'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             onOptionSelected(ExportOption.allData);
//             Navigator.of(context, rootNavigator: true).pop();
//           },
//           child: const Text('Wszystkie dane'),
//         ),
//         TextButton(
//           onPressed: () {
//             onOptionSelected(ExportOption.filteredData);
//             Navigator.of(context, rootNavigator: true).pop();
//           },
//           child: const Text('Tylko przefiltrowane'),
//         ),
//       ],
//     );
//   }
// }