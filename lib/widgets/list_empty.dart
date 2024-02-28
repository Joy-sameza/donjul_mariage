import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingEmpty extends StatelessWidget {
  const LoadingEmpty({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    var emptyListIcon = CupertinoIcons.zzz;
    var color = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyListIcon,
            color: color,
            size: MediaQuery.of(context).size.width * 0.35,
          ),
          const SizedBox(height: 10),
          Text(
            'Nothing found',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
