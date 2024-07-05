// TODO : Nie wszystkie wydatki dodają się od razu do synchronizacji
// TODO : Ustawić zapisywanie danych lokalnie dla użytkownika i ładowanie ich przy przelogowaniu
// TODO : Dodać pobieranie z bazy danych (Porównywanie istniejących danych (o konkretnym ID)  a jeśli brakuje ID to pobrać)
import 'package:expenses_app_project/Repositories/Local%20Data/expenses_list_element.dart';
import 'package:expenses_app_project/Repositories/Online%20Data/firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../Authentication/auth_service.dart';
import '../../main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
FirestoreService firestore = FirestoreService();
bool _isSyncing = false;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await syncWithFirebase();
    return Future.value(true);
  });
}

Future<void> syncWithFirebase() async {
  if (_isSyncing) return;

  _isSyncing = true;

  try {
    await initializeNotifications();
    var box = await Hive.openBox<ExpensesListElementModel>(AuthService().getBoxName());

    await doubleCheckExpensesToSync(box);

    await syncExpenses(box);
  } catch (e) {
    notifyError('Wystąpił błąd: $e');
  } finally {
    _isSyncing = false;
  }
}

Future<void> initializeNotifications() async {
  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

List<ExpensesListElementModel> getExpensesToSync(Box<ExpensesListElementModel> box) {
  List<ExpensesListElementModel> localExpenses = box.values.toList();
  return localExpenses.where((expense) => expense.toBeSent || expense.toBeUpdated || expense.toBeDeleted).toList();
}

Future<void> doubleCheckExpensesToSync(Box<ExpensesListElementModel> box) async {
  await Future.delayed(const Duration(milliseconds: 100)); // Krótkie opóźnienie, aby upewnić się, że dane są aktualne
  List<ExpensesListElementModel> expensesToSync = getExpensesToSync(box);

  // Sprawdzenie i ewentualna aktualizacja listy wydatków do synchronizacji
  if (expensesToSync.isNotEmpty) {
    await Future.delayed(const Duration(milliseconds: 100)); // Kolejne krótkie opóźnienie
    expensesToSync = getExpensesToSync(box);
  }
}


// TODO : Jeśli online nie ma wydatku a jest lokalnie to usunąć lokalnie
// TODO : Jeśli online jest wydatek a lokalnie nie to dodać lokalnie
Future<void> syncExpenses(Box<ExpensesListElementModel> box) async {
  int processedExpenses = 0;
  List<ExpensesListElementModel> expensesToSync;

  do {
    // Pobierz lokalne wydatki do synchronizacji
    expensesToSync = getExpensesToSync(box);
    int totalExpenses = processedExpenses + expensesToSync.length;

    // Synchronizacja lokalnych wydatków
    for (var expense in expensesToSync) {
      if (expense.toBeSent) {
        await syncExpense(box, expense.copyWith(toBeSent: false), ExpenseAction.addToFirebase);
      } else if (expense.toBeUpdated) {
        await syncExpense(box, expense.copyWith(toBeUpdated: false), ExpenseAction.updateToFirebase);
      } else if (expense.toBeDeleted) {
        await deleteExpense(box, expense);
      }

      processedExpenses++;
      await showProgressNotification(processedExpenses, totalExpenses);
    }

    // Pobierz dane z Firebase
    List<ExpensesListElementModel> onlineExpenses = await firestore.getFirebaseData();
    int onlineTotalExpenses = onlineExpenses.length;
    totalExpenses += onlineTotalExpenses; // Aktualizacja całkowitej liczby elementów

    // TODO : Aktualnie wszystkie online są zaliczane jako totalExpenses mimo że są lokalnie
    if (totalExpenses == 0) {
      await showCompletionNotification();
      return;
    }

    // Synchronizacja wydatków z Firebase
    for (var onlineExpense in onlineExpenses) {
      var localExpense = box.values.cast<ExpensesListElementModel?>().firstWhere(
        (expense) => expense?.firebaseId == onlineExpense.firebaseId,
        orElse: () => null);

      if (localExpense == null) {
        // Jeśli online jest wydatek a lokalnie nie ma, dodaj lokalnie
        await box.put(onlineExpense.localId, onlineExpense);
      } else {
        // Jeśli online jest zmodyfikowany, zaktualizuj lokalnie
        if (!onlineExpense.equalsIgnoringHashCode(localExpense)) {
          await box.put(localExpense.localId, onlineExpense);
        }
      }

      processedExpenses++;
      await showProgressNotification(processedExpenses, totalExpenses);
    }

    // Usuń lokalne wydatki, których nie ma online
    for (var localExpense in box.values) {
      if (localExpense.firebaseId != null && !onlineExpenses.any((onlineExpense) => onlineExpense.firebaseId == localExpense.firebaseId)) {
        await box.delete(localExpense.localId);
        processedExpenses++;
        await showProgressNotification(processedExpenses, totalExpenses);
      }
    }

  } while (getExpensesToSync(box).isNotEmpty);

  if (processedExpenses > 0) {
    await showCompletionNotification();
  }
}

Future<int> fetchMissingData(Box<ExpensesListElementModel> box, int currentProgress) async {
  try {
    List<ExpensesListElementModel> onlineExpenses = await firestore.getFirebaseData();

    int totalExpenses = onlineExpenses.length;
    int processedExpenses = 0;

    for (var onlineExpense in onlineExpenses) {
      if (!box.values.any((localExpense) => localExpense.firebaseId == onlineExpense.firebaseId)) {
        await box.put(onlineExpense.localId, onlineExpense);
      }

      processedExpenses++;
      await showProgressNotification(currentProgress + processedExpenses, currentProgress + totalExpenses);
    }

    return totalExpenses;
  } catch (e) {
    notifyError('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    return 0;
  }
}

Future<void> syncExpense(Box<ExpensesListElementModel> box, ExpensesListElementModel expense, ExpenseAction action) async {
  expense = await firestore.manageExpense(
    scaffoldMessengerKey: scaffoldMessengerKey,
    expense: expense,
    navigatorKey: navigatorKey,
    action: action,
  );
  await box.put(expense.localId, expense);
}

Future<void> deleteExpense(Box<ExpensesListElementModel> box, ExpensesListElementModel expense) async {
  await firestore.manageExpense(
    scaffoldMessengerKey: scaffoldMessengerKey,
    expense: expense,
    navigatorKey: navigatorKey,
    action: ExpenseAction.deleteOnFirebase,
  );
  await box.delete(expense.localId);
}

Future<void> showProgressNotification(int processedExpenses, int totalExpenses) async {
  int progress = ((processedExpenses / totalExpenses) * 100).toInt();
  await flutterLocalNotificationsPlugin.show(0, 'Synchronizacja', 'Synchronizacja danych: $progress% ($processedExpenses/$totalExpenses)', NotificationDetails(
      android: AndroidNotificationDetails(
        'sync_channel',
        'Synchronizacja',
        channelDescription: 'Powiadomienia o synchronizacji',
        showProgress: true,
        maxProgress: 100,
        progress: progress,
        ongoing: true,
        silent: true,
      ),
    ),
  );
}

Future<void> showCompletionNotification() async {
  var androidPlatformChannelSpecificsEnd = const AndroidNotificationDetails('sync_channel', 'Synchronizacja', channelDescription: 'Powiadomienia o synchronizacji');
  var platformChannelSpecificsEnd = NotificationDetails(android: androidPlatformChannelSpecificsEnd);

  await flutterLocalNotificationsPlugin.show(0, 'Synchronizacja', 'Zakończono synchronizację danych', platformChannelSpecificsEnd);
}

void notifyUser(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 400)));
}

void notifyError(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
}