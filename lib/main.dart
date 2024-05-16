import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const CSVReader({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CSVReaderState createState() => _CSVReaderState();
}

class _CSVReaderState extends State<CSVReader> {
  List<List<dynamic>> csvData = [];
  final Logger _logger = Logger();
  final totalCost = null;

  Future<void> loadCSV() async {
    setState(() {
      csvData = [];
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv']
    );

    if (result != null) {
      try {
        final input = File(result.files.single.path!).openRead();
        final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter(fieldDelimiter: ";")).toList();

        setState(() {
          csvData = fields;
          csvData.removeAt(0);
        });

      } catch (e) {
        _logger.e('Błąd podczas przetwarzania pliku CSV: $e'); // Przetestować
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
                        
                  final String pricePerUnit = row[5].replaceAll(' zł', '').replaceAll(',', '.'); // Usunięcie " zł" i zamiana przecinka na kropkę
                  final double pricePerUnitFloat = double.tryParse(pricePerUnit) ?? 0.0; // Konwersja na float, obsługa przypadku gdy wartość nie jest liczbą
                  final double deliveryCostFloat = double.tryParse(row[8].replaceAll(' zł', '').replaceAll(',', '.')) ?? 0.0; // Obsługa pustego stringa, ustawienie na zero
                  final totalCost = row[4] * pricePerUnitFloat + deliveryCostFloat; // Obliczenie kosztu całkowitego

                  // // Rozbicie daty na części
                  // List<String> parts = row[0].split('.');

                  // // Przekształcenie części na liczby
                  // int day = int.parse(parts[0]);
                  // int month = int.parse(parts[1]);
                  // int year = int.parse(parts[2]);

                  // // Liczba dni od daty bazowej (01.01.1900) do danej daty
                  // // DateTime baseDate = DateTime(1900, 1, 1);
                  // DateTime currentDate = DateTime(year, month, day);
                  // int daysDifference = currentDate.difference(baseDate).inDays;


                  return ExpansionTile(
                    title: Row(
                      children: [
                        SizedBox(
                          width: 100, // Stała szerokość dla pierwszej kolumny
                          child: Text('${row[0]}'),
                        ),
                        Expanded(
                          child: Text('${row[3]}'), // Automatyczna szerokość dla środkowej kolumny
                        ),
                        SizedBox(
                          width: 70, // Stała szerokość dla ostatniej kolumny
                          child: Text('${totalCost.toStringAsFixed(2)} zł'),
                        ),
                      ],
                    ),
                    trailing: const SizedBox.shrink(), // Usunięcie ikony rozwijania
                    collapsedBackgroundColor: row[0] != csvData[index+1][0] ? Colors.grey[200] : Colors.white, // Zmiana koloru tła co drugiego wiersza
                    children: [
                      ListTile(
                        title: Text('Produkt: ${row[3]}'),
                      ),
                      ListTile(
                        title: Text('Ilość: ${row[4]}'),
                      ),
                      ListTile(
                        title: Text('Cena za sztukę: ${row[5]}'),
                      ),
                      ListTile(
                        title: Text('Ilość w miarę: ${row[6]}'),
                      ),
                      ListTile(
                        title: Text('Ilość w opakowaniu: ${row[7]}'),
                      ),
                      ListTile(
                        title: Text('Koszt dostawy: ${row[8]}'),
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