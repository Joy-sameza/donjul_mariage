import 'package:flutter/material.dart';

Future<void> snackBarMethod(
    {required BuildContext context,
    String? response,
    int? duration,
    required double width}) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        response ?? 'Something went wrong',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.bold,
          fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
        ),
      ),
      width: width,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      duration: Duration(seconds: duration ?? 3),
    ),
  );
}
