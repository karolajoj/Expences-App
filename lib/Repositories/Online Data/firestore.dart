import 'package:expenses_app_project/Repositories/Local%20Data/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ExpenseAction { addToFirebase, updateToFirebase, deleteOnFirebase, addToLocal, updateToLocal, deleteOnLocal }

class FirestoreService {
  Future<ExpensesListElementModel> manageExpense({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required ExpensesListElementModel expense,
    required GlobalKey<NavigatorState> navigatorKey,
    required ExpenseAction action,
  }) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // throw Exception('Nie zalogowano użytkownika');
        return expense;
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
        return expenseWithUid;

      } else if (action == ExpenseAction.updateToFirebase || action == ExpenseAction.deleteOnFirebase) {
        final String? firebaseId = expense.firebaseId;
        if (firebaseId == null) {
          return expense;
        }
        final DocumentReference expenseRef = userExpenses.doc(firebaseId);

        if (action == ExpenseAction.updateToFirebase) {
          await expenseRef.update(expense.toMap());
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatek zaktualizowany pomyślnie')));
        } else if (action == ExpenseAction.deleteOnFirebase) {
          await expenseRef.delete();
          scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatek usunięty pomyślnie')));
        }
      }
      return expense;
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text('Wystąpił błąd: $e')));
       rethrow;
    }
  }

  Future<List<ExpensesListElementModel>> getFirebaseData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // throw Exception('Nie zalogowano użytkownika');
        return [];
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