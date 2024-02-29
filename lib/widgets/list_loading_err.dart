import 'package:flutter/cupertino.dart';
import 'package:marriage_app/widgets/custom_error.dart';

class ListError extends StatelessWidget {
  const ListError({super.key, required this.retry, this.exception});
  final Future<void> Function() retry;
  final Exception? exception;

  @override
  Widget build(BuildContext context) {
    return CustomError(
      errorMessage: "Error loading data",
      exception: exception,
      onRetry: retry,
    );
  }
}
