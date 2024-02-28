import 'package:flutter/cupertino.dart';
import 'package:marriage_app/widgets/custom_error.dart';

class ListError extends StatelessWidget {
  const ListError({super.key, required this.retry});
  final Future<void> Function() retry;

  @override
  Widget build(BuildContext context) {
    return CustomError(
      errorMessage: "Error loading data",
      onRetry: retry,
    );
  }
}
