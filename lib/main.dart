import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marriage_app/config/color_schemes.g.dart';
import 'package:marriage_app/pages/admin_only/add_guest.dart';
import 'package:marriage_app/pages/admin_only/admin_guest_list.dart';
import 'package:marriage_app/pages/admin_only/admin_home.dart';
import 'package:marriage_app/pages/admin_only/add_user.dart';
import 'package:marriage_app/pages/admin_only/admin_user_details.dart';
import 'package:marriage_app/pages/admin_only/admin_user_list.dart';
import 'package:marriage_app/pages/user_home.dart';
import 'package:marriage_app/pages/loading_screen.dart';
import 'package:marriage_app/pages/login.dart';
import 'package:marriage_app/pages/result_screen.dart';
import 'package:marriage_app/pages/splash_screen.dart';
import 'package:marriage_app/config/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MarriageApp());
}

class MarriageApp extends StatelessWidget {
  const MarriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final appColorScheme =
        brightness == Brightness.dark ? darkColorScheme : lightColorScheme;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marriage App',
      routes: {
        '/': (context) => const Splash(),
        '/home': (context) => const UserHome(),
        '/login': (context) => const Login(),
        '/result': (context) => const Result(),
        '/loading': (context) => const Loading(),
        '/admin': (context) => const AdminHome(),
        '/admin/add_user': (context) => const AddUser(),
        '/admin/user_details': (context) => const UserDetails(),
        '/admin/user_list': (context) => const UserList(),
        '/admin/add_guest': (context) => const AddGuest(),
        '/admin/guest_list': (context) => const GuestList(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: appColorScheme,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Configuration.mainGrey),
          bodyMedium: TextStyle(color: Configuration.mainGrey),
        ),
        fontFamily: 'Fira Code',
      ),
    );
  }
}
