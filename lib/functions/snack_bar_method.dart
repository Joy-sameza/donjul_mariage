import 'package:flutter/material.dart';

snackBarMethod(
    {required BuildContext context,
    String? message,
    int? duration,
    bool hasError = false,
    double? width}) {
  final Size screenSize = MediaQuery.of(context).size;
  width = width ?? screenSize.width * 0.75;

  ThemeData themeContext = Theme.of(context);
  Map<String, Map<String, Color>> snackBarColor = {
    'success': {
      'container': themeContext.colorScheme.tertiaryContainer,
      'text': themeContext.colorScheme.onTertiaryContainer
    },
    'error': {
      'container': themeContext.colorScheme.errorContainer,
      'text': themeContext.colorScheme.error
    }
  };

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message ?? 'Something went wrong',
        style: TextStyle(
          color: snackBarColor[hasError ? 'error' : 'success']!['text'],
          fontWeight: FontWeight.bold,
          fontSize: themeContext.textTheme.bodyMedium!.fontSize,
        ),
      ),
      width: width,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor:
          snackBarColor[hasError ? 'error' : 'success']!['container'],
      duration: Duration(seconds: duration ?? 3),
    ),
  );
}
