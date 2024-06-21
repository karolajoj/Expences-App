// import 'package:expenses_app_project/Repositories/Local%20Data/expenses_list_element.dart';
// import 'package:expenses_app_project/Repositories/Online%20Data/firestore.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
// FirestoreService firestore = FirestoreService();

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     await syncWithFirebase();
//     return Future.value(true);
//   });
// }

// // TODO : E/flutter (28926): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: 
// // PlatformException(flutter_background.PermissionHandler, 
// // The app does not have the REQUEST_IGNORE_BATTERY_OPTIMIZATIONS permission required to ask the user for whitelisting. 
// // See the documentation on how to setup this plugin properly., null, null)
// Future<void> syncWithFirebase() async {
//   var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
//   List<ExpensesListElementModel> localExpenses = box.values.toList();

//   for (var expense in localExpenses) {
//     bool toBeSent = expense.toBeSent;
//     bool toBeUpdated = expense.toBeUpdated;
//     bool toBeDeleted = expense.toBeDeleted;

//     if (toBeSent) {
//       expense = expense.copyWith(toBeSent: false);
//       await firestore.manageExpense(
//         scaffoldMessengerKey: scaffoldMessengerKey,
//         expense: expense,
//         navigatorKey: navigatorKey,
//         action: ExpenseAction.addToFirebase,
//       );
//       await box.put(expense.localId, expense);
//     }
//     if (toBeUpdated) {
//       expense = expense.copyWith(toBeUpdated: false);
//       await firestore.manageExpense(
//         scaffoldMessengerKey: scaffoldMessengerKey,
//         expense: expense,
//         navigatorKey: navigatorKey,
//         action: ExpenseAction.updateToFirebase,
//       );
//       await box.put(expense.localId, expense);
//     }
//     if (toBeDeleted) {
//       await firestore.manageExpense(
//         scaffoldMessengerKey: scaffoldMessengerKey,
//         expense: expense,
//         navigatorKey: navigatorKey,
//         action: ExpenseAction.deleteOnFirebase,
//       );
//       await box.delete(expense.localId);
//     }
//   }
// }
