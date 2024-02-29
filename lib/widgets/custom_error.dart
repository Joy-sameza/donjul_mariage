import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  const CustomError(
      {super.key,
      required this.errorMessage,
      this.exception,
      required this.onRetry});
  final String errorMessage;
  final Exception? exception;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    String exceptionMessage = exception?.toString() ?? '';
    String displayMessage = exceptionMessage.isNotEmpty ? exceptionMessage : errorMessage;
    var errorIcon = Icons.error_outline_rounded;
    if (exception is TimeoutException) {
      errorIcon = Icons.cloud_off_rounded;
    }
    //check internet connection
    if (exception is SocketException) {
      errorIcon = Icons.wifi_off_rounded;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            errorIcon,
            color: Theme.of(context).colorScheme.error,
            size: MediaQuery.of(context).size.width * 0.35,
          ),
          const SizedBox(height: 10),
          Text(
            displayMessage.split(':').last,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async => await onRetry(),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
