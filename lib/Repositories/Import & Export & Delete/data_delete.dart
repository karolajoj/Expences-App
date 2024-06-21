import '../Local Data/expenses_list_element.dart';
import '../Local Data/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'data_utils.dart';

// Future<void> deleteAllData(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, Function loadOrRefreshLocalData, ExpensesProvider expensesProvider, GlobalKey<NavigatorState> navigatorKey) async {
//   var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
//   int count = box.length;

//   if (count == 0) {
//     scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do usunięcia')));
//     return;
//   }

//   final bool? confirm = await showConfirmationDialog('Potwierdzenie usunięcia','Czy na pewno chcesz usunąć te dane?\nŁącznie : $count wydatków',navigatorKey,);

//   if (confirm != true) {return;}

//   showLoadingDialog(navigatorKey);

//   await expensesProvider.deleteAllExpense();

//   bool allDeleted = false;
//   while (!allDeleted) {
//     var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
//     if (box.isEmpty) {
//       allDeleted = true;
//     } else {
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   navigatorKey.currentState?.pop();

//   await loadOrRefreshLocalData();

//   scaffoldMessengerKey.currentState?.showSnackBar(
//     SnackBar(content: Text('Wszystkie dane zostały usunięte: $count wydatków')),
//   );
// }

// Future<void> deleteFilteredData(BuildContext context, List<ExpensesListElementModel> filteredData, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, Function loadOrRefreshLocalData, ExpensesProvider expensesProvider, GlobalKey<NavigatorState> navigatorKey) async {
//   int count = filteredData.length;

//   if (count == 0) {
//     scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do usunięcia')));
//     return;
//   }

//   final bool? confirm = await showConfirmationDialog('Potwierdzenie usunięcia', 'Czy na pewno chcesz usunąć te dane?\nŁącznie : $count wydatków', navigatorKey);

//   if (confirm != true) {return;}

//   showLoadingDialog(navigatorKey);

//   for (var expense in filteredData) {
//     await expensesProvider.deleteExpense(expense.localId);
//   }

//   bool allDeleted = false;
//   List<ExpensesListElementModel> notDeleted = [];
//   while (!allDeleted) {
//     notDeleted.clear();
//     for (var expense in filteredData) {
//       if (expensesProvider.getExpenseById(expense.localId) != null) {
//         notDeleted.add(expense);
//       }
//     }
//     if (notDeleted.isEmpty) {
//       allDeleted = true;
//     } else {
//       await Future.delayed(const Duration(milliseconds: 100));
//     }
//   }

//   navigatorKey.currentState?.pop();

//   await loadOrRefreshLocalData();

//   scaffoldMessengerKey.currentState?.showSnackBar(
//     SnackBar(content: Text('Przefiltrowane dane zostały usunięte: $count wydatków')),
//   );
// }

// TODO : nie działą (po uruchomieniu aplikacji dane są nadal w bazie)
Future<void> markAllDataForDeletion(BuildContext context, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, Function loadOrRefreshLocalData, ExpensesProvider expensesProvider, GlobalKey<NavigatorState> navigatorKey) async {
  var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
  int count = box.length;

  if (count == 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do usunięcia')));
    return;
  }

  final bool? confirm = await showConfirmationDialog('Potwierdzenie usunięcia', 'Czy na pewno chcesz oznaczyć te dane do usunięcia?\nŁącznie : $count wydatków', navigatorKey);

  if (confirm != true) {return;}

  showLoadingDialog(navigatorKey);

  for (var key in box.keys) {
    var expense = box.get(key);
    if (expense != null) {
      await expensesProvider.setForDeletion(expense.localId);
    }
  }

  box.close();
  
  navigatorKey.currentState?.pop();

  await loadOrRefreshLocalData();

  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wszystkie dane zostały oznaczone do usunięcia: $count wydatków')));
}

Future<void> markFilteredDataForDeletion(BuildContext context, List<ExpensesListElementModel> filteredData, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey, Function loadOrRefreshLocalData, ExpensesProvider expensesProvider, GlobalKey<NavigatorState> navigatorKey) async {
  int count = filteredData.length;

  if (count == 0) {
    scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Brak danych do usunięcia')));
    return;
  }

  final bool? confirm = await showConfirmationDialog('Potwierdzenie usunięcia', 'Czy na pewno chcesz oznaczyć te dane do usunięcia?\nŁącznie : $count wydatków', navigatorKey);

  if (confirm != true) {return;}

  showLoadingDialog(navigatorKey);

  for (var expense in filteredData) {
    await expensesProvider.setForDeletion(expense.localId);
  }

  navigatorKey.currentState?.pop();

  await loadOrRefreshLocalData();

  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text('Przefiltrowane dane zostały oznaczone do usunięcia: $count wydatków')),
  );
}