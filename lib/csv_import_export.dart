import 'package:expenses_app_project/csv_loader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'expenses_list_element.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

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

    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Dane zostały zaimportowane')));
  }).loadCSV(context);
}

Future<void> exportCSV(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, List<ExpensesListElementModel> csvData) async {
  List<List<dynamic>> rows = [["Data", "Sklep", "Kategoria", "Produkt", "Ilość", "Cena", "Miara", "Ilość w opakowaniu", "Zwrot", "Koszt Dostawy", "Link", "Komentarz"]];

  for (var element in csvData) {
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
  if (directory != null) {
    final path = "$directory/wydatki_export.csv";
    final file = File(path);
    await file.writeAsString(csvDataString, encoding: utf8);

    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wyeksportowano plik CSV do: $path')));
  } else {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Nie wybrano ścieżki')));
  }
}