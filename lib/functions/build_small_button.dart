import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';

Widget buildSmallButton(bool isDone) {
  final colors = isDone ? Colors.green : Configuration.mainBlue;
  return Container(
    height: 60,
    decoration: BoxDecoration(shape: BoxShape.circle, color: colors),
    child: Center(
      child: isDone
          ? const Icon(Icons.done, size: 30, color: Colors.white)
          : const CircularProgressIndicator(
        color: Colors.white,
        strokeCap: StrokeCap.round,
      ),
    ),
  );
}