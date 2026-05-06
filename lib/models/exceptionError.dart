import 'package:flutter/material.dart';

class Exceptionerror implements Exception {
  static final String message = 'An error occurred';

  @override
  String toString() => 'Exceptionerror: $message';

  static void SnackBarError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void AlertDialogError(BuildContext context) {
    showDialog(
      context: context,
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
