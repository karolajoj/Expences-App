import 'dart:convert';
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
      title: 'CSV Reader',
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
  _CSVReaderState createState() => _CSVReaderState();
}

class _CSVReaderState extends State<CSVReader> {
  List<List<dynamic>> csvData = [];
  final Logger _logger = Logger();

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
        final fields = await input.transform(utf8.decoder).transform(CsvToListConverter(fieldDelimiter: ";")).toList();

        setState(() {
          csvData = fields;
        });
      } catch (e) {
        _logger.e('Błąd podczas przetwarzania pliku CSV: $e');
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
                  List<dynamic> row = csvData[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data: ${row[0]}'),
                        Text('Sklep: ${row[1]}'),
                        Text('Kategoria: ${row[2]}'),
                        Text('Produkt: ${row[3]}'),
                        Text('Ilość: ${row[4]}'),
                        Text('Cena za sztukę: ${row[5]}'),
                        Text('Ilość w miarę: ${row[6]}'),
                        Text('Ilość w opakowaniu: ${row[7]}'),
                        Text('Koszt dostawy: ${row[8]}'),
                      ],
                    ),
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
