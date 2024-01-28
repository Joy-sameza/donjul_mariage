import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget logout(BuildContext context) {
  return ElevatedButton(
    onPressed: (() async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.remove('auth_token');
    }),
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: const Text('Logout'),
  );
}
