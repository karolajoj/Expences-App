import 'package:expenses_app_project/Repositories/Local%20Data/expenses_list_element.dart';
import 'package:expenses_app_project/firebase_options.dart';
import 'package:expenses_app_project/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();
// TODO: WSZĘDZIE UŻYWAĆ navigatorKey zamiast BuildContext
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesListElementModelAdapter());
  await Hive.openBox<ExpensesListElementModel>('expenses_local');

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
      home: const MainPage(),
      navigatorKey: navigatorKey,
    );
  }
}