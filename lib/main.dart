import 'package:flutter/material.dart';
import 'csv_reader.dart';
// import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // setWindowMinSize(const Size(1080/2.3, 2460/2.3));
  // setWindowMaxSize(const Size(1080/2.3, 2460/2.3));
  // setWindowFrame(const Rect.fromLTWH(0, 0, 1080/2.3, 2460/2.3));

  runApp(const ExpensesApp());
}

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista wydatków',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CSVReader(),
    );
  }
}