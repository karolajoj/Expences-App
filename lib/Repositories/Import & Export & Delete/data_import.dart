import 'package:expenses_app_project/Utils/utils.dart';
import '../Local Data/expenses_list_element.dart';
import 'package:expenses_app_project/main.dart';
import 'package:file_picker/file_picker.dart';
import '../Local Data/expenses_provider.dart';
import '../Online Data/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'data_utils.dart';
import 'dart:convert';
import 'dart:io';

ExpensesProvider expensesProvider = ExpensesProvider(Hive.box<ExpensesListElementModel>('expenses_local'));

Future<void> loadCSV(
  Function(void Function()) setState,
  List<ExpensesListElementModel> csvData,
  List<ExpensesListElementModel> filteredData,
  Map<String, Color> dateColorMap,
  VoidCallback applyDefaultFilters,
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  bool keepCurrentData) async {

  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

  if (result != null) {
    List<ExpensesListElementModel> csvDataList = await _parseCSV(result.files.single.path!);

    bool? confirm = await showConfirmationDialog('Potwierdzenie importu', 'Czy na pewno chcesz zaimportować te dane?\n${keepCurrentData ? '' : 'Obecne dane zostaną zastąpione nowymi\n'}Łącznie : ${csvDataList.length} wydatków', navigatorKey);

    if (confirm == true) {
      await _handleCSVData(csvDataList, setState, csvData, filteredData, dateColorMap, applyDefaultFilters, scaffoldMessengerKey, keepCurrentData);
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Import anulowany')));
    }
  } else {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Import anulowany')));
  }
}

Future<List<ExpensesListElementModel>> _parseCSV(String filePath) async {
  final input = File(filePath).openRead();
  final fields = await input
      .transform(utf8.decoder)
      .transform(const CsvToListConverter(fieldDelimiter: ";"))
      .toList();

  fields.removeAt(0);

  return fields.map((row) {
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
      toBeSent: true,
    );
  }).toList();
}

Future<void> _handleCSVData(
  List<ExpensesListElementModel> csvDataList,
  Function(void Function()) setState,
  List<ExpensesListElementModel> csvData,
  List<ExpensesListElementModel> filteredData,
  Map<String, Color> dateColorMap,
  VoidCallback applyDefaultFilters,
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  bool keepCurrentData) async {

  if (!keepCurrentData) {
    expensesProvider.setAllForDeletion();
  }
  
  setState(() {
    if (!keepCurrentData) {
      csvData.clear();
      filteredData.clear();
      dateColorMap.clear();
    }
    csvData.addAll(csvDataList);
    filteredData.addAll(csvDataList);

    applyDefaultFilters();
    updateDateColorMap(filteredData, dateColorMap);
  });

  var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');

  for (var expense in csvDataList) {
    await box.put(expense.localId, expense);
  }

  syncWithFirebase();

  scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Dane zostały zaimportowane')));
}