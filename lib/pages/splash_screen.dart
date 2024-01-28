import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> loadMainData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('auth_token');
    final bool? isAdmin = prefs.getBool('isAdmin');
    await Future.delayed(const Duration(seconds: 2));
    if (authToken != null && isAdmin != null) {
      if (isAdmin) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/admin');
        return;
      }
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    loadMainData();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FittedBox(
          child: Text(
            'Welcome to Donjul Marriage',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
