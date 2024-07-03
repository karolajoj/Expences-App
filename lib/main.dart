import 'package:expenses_app_project/Repositories/Local%20Data/expenses_list_element.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:expenses_app_project/Main%20Pages/main_page.dart';
import 'package:expenses_app_project/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Repositories/Online Data/sync_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(ExpensesListElementModelAdapter());
  await Hive.openBox<ExpensesListElementModel>('expenses_local');

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await requestNotificationPermissions();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);


  runApp(const ExpensesApp());
}

Future<void> requestNotificationPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
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
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}