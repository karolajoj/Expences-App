import 'package:expenses_app_project/Main%20Pages/Expenses%20List/expenses_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? userEmail = userCredential.user?.email;
      final String? userName = userEmail?.split('@').first;

      // Aktualizacja nazwy użytkownika w Firebase Auth
      await userCredential.user?.updateDisplayName(userName);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const ExpensesPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Wystąpił błąd podczas rejestracji użytkownika: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const ExpensesPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Wystąpił błąd podczas logowania użytkownika: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const ExpensesPage()),
      );
    }
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

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}