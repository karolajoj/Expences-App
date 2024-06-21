import '../Local Data/expenses_list_element.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

Future<void> exportCSV(
  BuildContext context,
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  List<ExpensesListElementModel> exportData) async {
    
  if (exportData.isEmpty) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do eksportu')));
    return;
  }

  List<List<dynamic>> rows = _generateCSVRows(exportData);

  String csvDataString = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

  final directory = await FilePicker.platform.getDirectoryPath();
  String date = DateFormat('dd.MM.yyyy').format(DateTime.now());
  if (directory != null) {
    await _writeCSVFile(directory, date, csvDataString, scaffoldMessengerKey);
  } else {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Nie wybrano ścieżki')));
  }
}

List<List<dynamic>> _generateCSVRows(List<ExpensesListElementModel> exportData) {
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

  return rows;
}

Future<void> _writeCSVFile(
  String directory,
  String date,
  String csvDataString,
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) async {

  final path = "$directory/expenses_data-$date.csv";
  final file = File(path);

  try {
    await file.writeAsString(csvDataString, encoding: utf8);  
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wyeksportowano plik CSV do: $path')));
  } catch (e) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wystąpił błąd podczas eksportu danych: $e')));  
  }
}