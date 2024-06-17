import '../Local Data/expenses_list_element.dart';
import 'package:expenses_app_project/utils.dart';
import 'package:expenses_app_project/main.dart';
import 'package:file_picker/file_picker.dart';
import '../Local Data/expenses_provider.dart';
import 'package:flutter/material.dart';
import '../Online Data/firestore.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';

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

    bool? confirm = await _showConfirmationDialog(
      'Potwierdzenie importu',
      'Czy na pewno chcesz zaimportować te dane?\n${keepCurrentData ? '' : 'Obecne dane zostaną zastąpione nowymi\n'}Łącznie : ${csvDataList.length} wydatków',
      navigatorKey,
    );

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
    );
  }).toList();
}

// TODO : Przy usuwaniu lokalnie, ustawić flagę do usunięcia z Firebase ??
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
    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    await box.clear();
  }
  
  setState(() {
    if (!keepCurrentData) {
      csvData.clear();
      filteredData.clear();
      dateColorMap.clear();
    }
    csvData.addAll(csvDataList);
    filteredData.addAll(csvDataList);

    updateDateColorMap(csvData, dateColorMap);

    applyDefaultFilters();
  });

  var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
  await box.addAll(csvDataList);

  await FirestoreService().addExpenses(
    scaffoldMessengerKey: scaffoldMessengerKey,
    newExpenses: csvDataList,
    navigatorKey: navigatorKey
  );

  scaffoldMessengerKey.currentState?.showSnackBar(
    const SnackBar(content: Text('Dane zostały zaimportowane')),
  );
}

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

// TODO: Przenieść do utils.dart
Future<bool?> _showConfirmationDialog(String title, String content, GlobalKey<NavigatorState> navigatorKey) {
  return showDialog<bool>(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
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

void _showLoadingDialog(GlobalKey<NavigatorState> navigatorKey) {
  showDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Trwa usuwanie danych...")),
          ],
        ),
      );
    },
  );
}

Future<void> deleteAllData(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, Function loadOrRefreshLocalData, ExpensesProvider expensesProvider, GlobalKey<NavigatorState> navigatorKey) async {
  int count = await Hive.openBox<ExpensesListElementModel>('expenses_local').then((box) => box.length);

  if (count == 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do usunięcia')));
    return;
  }

  final bool? confirm = await _showConfirmationDialog('Potwierdzenie usunięcia','Czy na pewno chcesz usunąć te dane?\nŁącznie : $count wydatków',navigatorKey,);

  if (confirm != true) {return;}

  _showLoadingDialog(navigatorKey);

  bool allDeleted = false;

  while (!allDeleted) {
    await expensesProvider.deleteAllExpense();

    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    if (box.isEmpty) {
      allDeleted = true;
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  navigatorKey.currentState?.pop();

  await loadOrRefreshLocalData();

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text('Wszystkie dane zostały usunięte: $count wydatków')),
  );
}

// TODO : Dodać przycisk usuwania do każdego wydatku
// TODO : Dodać możliwość zaznaczenia kilku wydatków do usunięcia "usuń zaznaczone"
Future<void> deleteFilteredData(BuildContext context, List<ExpensesListElementModel> filteredData, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, Function loadOrRefreshLocalData, ExpensesProvider expensesProvider, GlobalKey<NavigatorState> navigatorKey) async {
  int count = filteredData.length;

  if (count == 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do usunięcia')));
    return;
  }

  final bool? confirm = await _showConfirmationDialog('Potwierdzenie usunięcia', 'Czy na pewno chcesz usunąć te dane?\nŁącznie : $count wydatków', navigatorKey);

  if (confirm != true) {return;}

  _showLoadingDialog(navigatorKey);

  bool allDeleted = false;
  List<ExpensesListElementModel> notDeleted = [];

  while (!allDeleted) {
    notDeleted.clear();
    for (var expense in filteredData) {
      await expensesProvider.deleteExpense(expense.localId);
    }

    for (var expense in filteredData) {
      if (expensesProvider.getExpenseById(expense.localId) != null) {
        notDeleted.add(expense);
      }
    }

    if (notDeleted.isEmpty) {
      allDeleted = true;
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  navigatorKey.currentState?.pop();

  await loadOrRefreshLocalData();

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text('Przefiltrowane dane zostały usunięte: $count wydatków')),
  );
}