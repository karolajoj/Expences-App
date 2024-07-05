import 'package:expenses_app_project/Main%20Pages/Expenses%20List/expenses_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Main Pages/main_page.dart';
import '../Repositories/Local Data/expenses_list_element.dart';


// TODO : Pytać użytkownika o migrację danych po zalogowaniu i jeśli tak to przenieść dane do zalogowanego użytkownika i usunąć z gościa.
class AuthService {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  String getBoxName() {
    var user = currentUser;
    return user != null ? 'expenses_local_${user.uid}' : 'expenses_local_guest';
  }

  Future<void> signup({
    required String email,
    required String password,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? userEmail = userCredential.user?.email;
      final String? userName = userEmail?.split('@').first;

      await userCredential.user?.updateDisplayName(userName);

      await _openUserBox();
      _navigateToExpensesPage(navigatorKey);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showErrorToast('Wystąpił błąd podczas rejestracji użytkownika: $e');
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _openUserBox();
      _navigateToMainPage(navigatorKey);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showErrorToast('Wystąpił błąd podczas logowania użytkownika: $e');
    }
  }

  Future<void> signout({required GlobalKey<NavigatorState> navigatorKey}) async {
    await _closeCurrentBox();
    await FirebaseAuth.instance.signOut();

    await _openUserBox();
    _navigateToMainPage(navigatorKey);
  }

  Future<void> _openUserBox() async {
    String boxName = getBoxName();
    await Hive.openBox<ExpensesListElementModel>(boxName);
  }

  Future<void> _closeCurrentBox() async {
    String boxName = getBoxName();
    var box = await Hive.openBox<ExpensesListElementModel>(boxName);
    await box.close();
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = '';
    if (e.code == 'weak-password') {
      message = 'Podane hasło jest zbyt słabe.';
    } else if (e.code == 'invalid-email') {
      message = 'Podany adres e-mail jest nieprawidłowy.';
    } else if (e.code == 'email-already-in-use') {
      message = 'Podany adres e-mail jest już w użyciu.';
    } else if (e.code == 'invalid-credential') {
      message = 'Podane dane są nieprawidłowe.';
    } else if (e.code == 'too-many-requests') {
      message = 'Zbyt wiele prób logowania. Spróbuj ponownie później.';
    } else {
      message = 'Błąd: $e';
    }

    _showErrorToast(message);
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _navigateToExpensesPage(GlobalKey<NavigatorState> navigatorKey) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const ExpensesPage()),
    );
  }

  void _navigateToMainPage(GlobalKey<NavigatorState> navigatorKey) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }
}