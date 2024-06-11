import 'package:expenses_app_project/expenses_list_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
    Future<void> addNewExpense({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    required ExpensesListElementModel newExpense,
    required BuildContext context,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      final CollectionReference userExpenses = FirebaseFirestore.instance
          .collection("MainCollection")
          .doc(user.uid)
          .collection("expenses");

      final DocumentReference newExpenseRef = await userExpenses.add(newExpense.toMap());
      final String expenseId = newExpenseRef.id;
      
      final ExpensesListElementModel expenseWithUid = ExpensesListElementModel(
        id: expenseId,
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
      
      await userExpenses.doc(expenseId).set(expenseWithUid.toMap()); // Ustawiamy dane z odpowiednim ID

      await syncData();
      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('Wydatek dodany pomyślnie')));
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Wystąpił błąd podczas dodawania wydatku : $e')),
      );
    }
  }
 
  Future<void> syncData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    List<ExpensesListElementModel> localData = await getLocalData();
    List<ExpensesListElementModel> firebaseData = await getFirebaseData();

    for (var localExpense in localData) {
      var firebaseExpense = firebaseData.firstWhere(
        (element) => element.id == localExpense.id,
        orElse: () => ExpensesListElementModel(id: '',data: DateTime.now(),sklep: '',kategoria: '',produkt: '',ilosc: 0,cena: 0.0,miara: 0,iloscWOpakowaniu: 0,kosztDostawy: 0.0,zwrot: false,link: '',komentarz: '',),
      );
      if (firebaseExpense.id != '') {
        updateLocalExpense(localExpense, firebaseExpense);
      } else {
        deleteLocalExpense(localExpense);
      }
    }

    await sendLocalChangesToFirebase();
  }

Future<List<ExpensesListElementModel>> getLocalData() async {
    // Implementacja pobierania danych z lokalnej bazy danych
    // Na razie zwracam pustą listę jako przykład
    return [];
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

  void updateLocalExpense(
      ExpensesListElementModel localExpense, ExpensesListElementModel firebaseExpense) {
    // Aktualizuj dane lokalnego wydatku
  }

  void deleteLocalExpense(ExpensesListElementModel localExpense) {
    // Usuń lokalny wydatek
  }

  Future<void> sendLocalChangesToFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      List<ExpensesListElementModel> localChanges = await getLocalData();

      if (user == null) {
        throw Exception('Nie zalogowano użytkownika');
      }

      for (var expense in localChanges) {
        final CollectionReference userExpenses = FirebaseFirestore.instance
            .collection("MainCollection")
            .doc(user.uid)
            .collection("expenses");

        await userExpenses.add(expense.toMap());
      }
    } catch (e) {
      throw Exception('Wystąpił błąd podczas wysyłania lokalnych zmian do Firebase: $e');
    }
  }
}