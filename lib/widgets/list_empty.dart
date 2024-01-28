import 'package:flutter/cupertino.dart';

class LoadingEmpty extends StatelessWidget {
  const LoadingEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No data',
      ),
    );
  }
}
