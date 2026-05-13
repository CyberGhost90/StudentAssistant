import 'package:flutter/material.dart';

class Exceptionerror implements Exception {
  static final String message = 'An error occurred';

  @override
  String toString() => 'Exceptionerror: $message';

  static void snackBarError(String message) {
    final snackBarKey = GlobalKey<ScaffoldMessengerState>();
    snackBarKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  static void alertDialogError(String message) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
