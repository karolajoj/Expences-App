import 'package:flutter/material.dart';
import 'csv_reader.dart';

void main() {
  runApp(const ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({super.key});

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