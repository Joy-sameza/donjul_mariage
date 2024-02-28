import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marriage_app/config/config.dart';

const Color indicatorColor = Colors.white;
final loadingIndicator = Platform.isAndroid
    ? const CircularProgressIndicator(
        color: indicatorColor,
        strokeCap: StrokeCap.round,
      )
    : const CupertinoActivityIndicator(color: indicatorColor);

Widget buildSmallButton(bool isDone) {
  final colors = isDone ? Colors.green : Configuration.mainBlue;
  return Container(
    height: 60,
    decoration: BoxDecoration(shape: BoxShape.circle, color: colors),
    child: Center(
      child: isDone
          ? const Icon(Icons.done, size: 30, color: Colors.white)
          : loadingIndicator,
    ),
  );
}
