import 'package:flutter/cupertino.dart';
import 'package:marriage_app/widgets/custom_error.dart';

class ListError extends StatelessWidget {
  const ListError({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomError(errorMessage: "Error loading data");
  }
}
