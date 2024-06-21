import 'package:expenses_app_project/Repositories/Local%20Data/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum ExpenseAction { addToFirebase, updateToFirebase, deleteOnFirebase, addToLocal, updateToLocal, deleteOnLocal}

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

// Czy przy wyjściu z okienka stanu kod sie anuluje?

  Future<void> addExpenses({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required List<ExpensesListElementModel> newExpenses,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      ValueNotifier<int> counter = ValueNotifier<int>(0);
      bool inBackground = false;

      // TODO : Umożliwić dodawanie w tle - (dodać dlagę do lokalnych wydatków "do wysłania") i przy każdym starcie aplikacji lub przy przeładowaniu listy wydatków synchronizować dane z firebase

      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: counter,
                          builder: (context, progressCount, _) {
                            double progress =
                                (progressCount / newExpenses.length) * 100;
                            return Text(
                                "Postęp: ${progress.toStringAsFixed(0)}% ($progressCount z ${newExpenses.length})");
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      inBackground = true;
                      navigatorKey.currentState?.pop();
                    },
                    child: const Text('Synchronizuj w tle'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final CollectionReference userExpenses = FirebaseFirestore.instance
          .collection("MainCollection")
          .doc(user.uid)
          .collection("expenses");

      for (var newExpense in newExpenses) {
        final DocumentReference newExpenseRef =
            await userExpenses.add(newExpense.toMap());
        final String firebaseId = newExpenseRef.id;

        final ExpensesListElementModel expenseWithUid =
            ExpensesListElementModel(
          localId: newExpense.localId,
          firebaseId: firebaseId,
          data: newExpense.data,
          sklep: newExpense.sklep,
          kategoria: newExpense.kategoria,
          produkt: newExpense.produkt,
          ilosc: newExpense.ilosc,
          cena: newExpense.cena,
          miara: newExpense.miara,
          miaraUnit: newExpense.miaraUnit,
          iloscWOpakowaniu: newExpense.iloscWOpakowaniu,
          kosztDostawy: newExpense.kosztDostawy,
          zwrot: newExpense.zwrot,
          link: newExpense.link,
          komentarz: newExpense.komentarz,
        );

        await userExpenses.doc(firebaseId).set(expenseWithUid.toMap());
        counter.value++;
      }

      if (!inBackground) {
        navigatorKey.currentState?.pop();
      }

      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatki dodane pomyślnie')));
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wystąpił błąd podczas dodawania wydatków: $e')));
    }
  }

  Future<void> manageExpense({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required ExpensesListElementModel expense,
    required GlobalKey<NavigatorState> navigatorKey,
    required ExpenseAction action,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      final CollectionReference userExpenses = FirebaseFirestore.instance
          .collection("MainCollection")
          .doc(user.uid)
          .collection("expenses");

      if (action == ExpenseAction.addToFirebase) {
        final DocumentReference newExpenseRef = await userExpenses.add(expense.toMap());
        final String firebaseId = newExpenseRef.id;

        final ExpensesListElementModel expenseWithUid = expense.copyWith(firebaseId: firebaseId);
        await userExpenses.doc(firebaseId).set(expenseWithUid.toMap());
        scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatek dodany pomyślnie')));

      } else if (action == ExpenseAction.updateToFirebase || action == ExpenseAction.deleteOnFirebase) {
        final String firebaseId = expense.firebaseId ?? (throw Exception('Wydatek nie ma przypisanego firebaseId'));
        final DocumentReference expenseRef = userExpenses.doc(firebaseId);

        if (action == ExpenseAction.updateToFirebase) {
          await expenseRef.update(expense.toMap());
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatek zaktualizowany pomyślnie')));

        } else if (action == ExpenseAction.deleteOnFirebase) {
          await expenseRef.delete();
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatek usunięty pomyślnie')));
        }
      }
      // TODO : Również zaktualizować lokalne dane w zależności od modyfikacji na serwerze
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wystąpił błąd: $e')));
    }
  }

  // TODO : Dopiero po usunięciu online można usunąć wydatek lokalnie
  Future<void> syncWithFirebase({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    var box = await Hive.openBox<ExpensesListElementModel>('expenses_local');
    List<ExpensesListElementModel> localExpenses = box.values.toList();

    for (var expense in localExpenses) {
      bool toBeSent = expense.toBeSent;
      bool toBeUpdated = expense.toBeUpdated;
      bool toBeDeleted = expense.toBeDeleted;

      if (toBeSent) {
        await manageExpense(
          scaffoldMessengerKey: scaffoldMessengerKey,
          expense: expense,
          navigatorKey: navigatorKey,
          action: ExpenseAction.addToFirebase,
        );
        expense = expense.copyWith(toBeSent: false);
        await box.put(expense.localId, expense);
      }
      if (toBeUpdated) {
        await manageExpense(
          scaffoldMessengerKey: scaffoldMessengerKey,
          expense: expense,
          navigatorKey: navigatorKey,
          action: ExpenseAction.updateToFirebase,
        );
        expense = expense.copyWith(toBeUpdated: false);
        await box.put(expense.localId, expense);
      }
      if (toBeDeleted) {
        await manageExpense(
          scaffoldMessengerKey: scaffoldMessengerKey,
          expense: expense,
          navigatorKey: navigatorKey,
          action: ExpenseAction.deleteOnFirebase,
        );
        await box.delete(expense.localId);
      }
    }
  }

  Future<List<ExpensesListElementModel>> getFirebaseData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("MainCollection")
              .doc(user.uid)
              .collection("expenses")
              .get();

      return querySnapshot.docs.map((doc) {
        return ExpensesListElementModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Wystąpił błąd podczas pobierania danych z Firebase: $e');
    }
  }
}
