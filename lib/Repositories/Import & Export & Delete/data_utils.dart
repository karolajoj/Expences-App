import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(String title, String content, GlobalKey<NavigatorState> navigatorKey) {
  return showDialog<bool>(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nie'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tak'),
          ),
        ],
      );
    },
  );
}

void showLoadingDialog(GlobalKey<NavigatorState> navigatorKey) {
  showDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Trwa usuwanie danych...")),
          ],
        ),
      );
    },
  );
}