import 'package:flutter/cupertino.dart';

@immutable
class Configuration {
  const Configuration();

  static const String apiUri = "https://mariage.donjul-service.com";//"http://192.168.8.101/auth";
  static const timeout = 10;

  //colors
  static const Color mainBlue = Color(0xff2f4f89);
  static const Color primaryAppColor = Color(0xfff57a2f);
  static const Color mainRed = Color.fromARGB(234, 219, 19, 12);
  static const Color mainGrey = Color(0xFF424242);
}
