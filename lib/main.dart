import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'expenses_list_element.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista wydatków',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CSVReader(),
    );
  }
}

class CSVReader extends StatefulWidget {
  const CSVReader({Key? key}) : super(key: key);

  @override
  _CSVReaderState createState() => _CSVReaderState();
}

class _CSVReaderState extends State<CSVReader> {
  List<ExpensesListElementModel> csvData = [];
  int sum = 0;

  Future<void> loadCSV() async {
    setState(() {
      csvData = [];
    });

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

    if (result != null) {
      try {
        final input = File(result.files.single.path!).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter(fieldDelimiter: ";"))
            .toList();

         setState(() {
          fields.removeAt(0); // Usuń nagłówek
          csvData = fields
              .map((row) => ExpensesListElementModel(
                      data: DateFormat('dd.MM.yyyy').parse(row[0]),
                      sklep: row[1],
                      kategoria: row[2],
                      produkt: row[3],
                      ilosc: row[4] ?? 0,
                      cena: row[5] == ""? 0.0: double.tryParse(row[5].replaceAll(' zł', '').replaceAll(',', '.').replaceAll(' ', '')) ??0.0,
                      miara: row[6] == "" ? null : row[6],
                      iloscWOpakowaniu:row[7] == "" ? null : row[7] ?? 0,
                      kosztDostawy: row[8] == "" ? null: double.tryParse(row[8].replaceAll(' zł', '').replaceAll(',', '.').replaceAll(' ', '')) ??0.0,
                      totalCost: 0.0, // Zaktualizuj, gdy obliczysz koszt całkowity
                      pricePerKg: 0.0, // Zaktualizuj, gdy obliczysz cenę za kg
                      pricePerPiece: 0.0, // Zaktualizuj, gdy obliczysz cenę za sztukę
                    ))
              .toList();
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Błąd"),
              content:
                  Text("Wystąpił błąd podczas przetwarzania pliku CSV: $e"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Reader'),
      ),
      body: Center(
        child: csvData.isEmpty
            ? const Text('Brak danych CSV')
            : ListView.builder(
                itemCount: csvData.length,
                itemBuilder: (BuildContext context, int index) {
                  final row = csvData[index];

                  // Tu możesz korzystać z danych z obiektu ExpensesListElementModel zamiast bezpośrednio z listy csvData

                  String currentDay = row.data.toString();
                  String? prevDay =
                      index > 0 ? csvData[index - 1].data.toString() : null;

                  // Sprawdź, czy aktualny dzień jest taki sam jak poprzedni element
                  int isDifferentDay = currentDay != prevDay ? 1 : 0;

                  sum = sum + isDifferentDay;

                  Color? rowColor =
                      sum % 2 == 0 ? Colors.grey[300] : Colors.blue[100];

                  return ExpansionTile(
                    title: Row(
                      children: [
                        SizedBox(
                          width: 100, // Stała szerokość dla pierwszej kolumny
                          child: Text('${row.data}'),
                        ),
                        Expanded(
                          child: Text(
                              '${row.produkt}'), // Automatyczna szerokość dla środkowej kolumny
                        ),
                        SizedBox(
                          width: 80, // Stała szerokość dla ostatniej kolumny
                          child: Text('${row.totalCost.toStringAsFixed(2)} zł'),
                        ),
                      ],
                    ),
                    trailing:
                        const SizedBox.shrink(), // Usunięcie ikony rozwijania
                    collapsedBackgroundColor: rowColor,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.red, // Kolor tła czerwony
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sklep: ${row.sklep}'),
                                  Text('Kategoria: ${row.kategoria}'),
                                  Text('Dostawa: ${row.kosztDostawy} zł'),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.red, // Kolor tła czerwony
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ilość: ${row.ilosc}'),
                                  Text('Miara: ${row.miara}'),
                                  Text('W opakowaniu: ${row.iloscWOpakowaniu}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text('Ilość w miarę: ${row.miara}'),
                      ),
                      ListTile(
                        title:
                            Text('Ilość w opakowaniu: ${row.iloscWOpakowaniu}'),
                      ),
                      ListTile(
                        title: Text('Koszt dostawy: ${row.kosztDostawy} zł'),
                      ),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadCSV();
        },
        tooltip: 'Wczytaj CSV',
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}
