import 'dart:convert';

import 'package:http/http.dart';
import 'package:marriage_app/config/config.dart';

class GetData {
  GetData();

  get data => _data;
  get status => _status;

  late dynamic _data;
  late int _status;
  final String _url = Configuration.apiUri;

  Future<void> loadUsers({int? adminId}) async {
    try {
      Response response = await get(
        Uri.parse('$_url/userList?admin=${adminId ?? 0}'),
        headers: {
          'Content-Type': 'application/json',
          "Access-Control-Allow-Origin": _url,
        },
      );
      _data = jsonDecode(response.body);
      _status = response.statusCode;
    } on Exception {
      _data = {'status': 500, 'message': 'An error occurred! Try again'};
      _status = 500;
    }
  }
}
