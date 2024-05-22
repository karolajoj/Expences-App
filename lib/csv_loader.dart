import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expenses_list_element.dart';

class CSVLoader {
  final Function(List<ExpensesListElementModel>) onDataLoaded;

  CSVLoader(this.onDataLoaded);

  Future<void> loadCSV(BuildContext context) async {
    List<ExpensesListElementModel> csvData = [];

    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

    if (result != null) {
      try {
        final input = File(result.files.single.path!).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter(fieldDelimiter: ";"))
            .toList();

        fields.removeAt(0); // Remove header

        csvData = fields.map((row) {
          return ExpensesListElementModel(
            data: DateFormat('dd.MM.yyyy').parse(row[0]),
            sklep: row[1],
            kategoria: row[2],
            produkt: row[3],
            ilosc: row[4] ?? 0,
            cena: row[5] == "" ? 0.0 : double.tryParse(row[5].replaceAll(' zł', '').replaceAll(',', '.').replaceAll(' ', '')) ?? 0.0,
            miara: row[6] == "" ? null : row[6],
            iloscWOpakowaniu: row[7] == "" ? null : row[7] ?? 0,
            zwrot: row[8] == "Tak" ? true : false,
            kosztDostawy: row[9] == "" ? null : double.tryParse(row[9].replaceAll(' zł', '').replaceAll(',', '.').replaceAll(' ', '')) ?? 0.0,
            link: row[10].replaceAll(' ', ''),
            komentarz: row[11],
          );
        }).toList();

        onDataLoaded(csvData);
      } catch (e) {
        if(context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Błąd"),
                content: Text(
                    "Wystąpił błąd podczas przetwarzania pliku CSV: $e"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
}