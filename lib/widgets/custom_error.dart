import 'dart:async';
import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  const CustomError({super.key, required this.errorMessage, this.exception});
  final String errorMessage;
  final Exception? exception;

  @override
  Widget build(BuildContext context) {
    var errorIcon = Icons.error_outline_rounded;
    if (exception is TimeoutException) {
      errorIcon = Icons.cloud_off_rounded;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            errorIcon,
            color: Theme.of(context).colorScheme.error,
            size: 50.0,
          ),
          const SizedBox(height: 10),
          Text(
            'An error occurred',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
            )
          )
        ],
      )
    );
  }
}
