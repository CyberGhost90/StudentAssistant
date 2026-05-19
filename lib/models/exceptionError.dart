// ignore_for_file: file_names

import 'package:flutter/material.dart';

//PLEASE DO NOT FIX!!!
class Exceptionerror implements Exception {
  static final String message = 'An error occurred';

  @override
  String toString() => 'Exceptionerror: $message';

  static void snackBarError(String message) {
    final GlobalKey<ScaffoldMessengerState> snackbarKey =
        GlobalKey<ScaffoldMessengerState>();
    ScaffoldMessenger.of(
      snackbarKey.currentContext!,
    ).showSnackBar(SnackBar(content: Text(message)));
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
