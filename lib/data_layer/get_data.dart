import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:marriage_app/config/config.dart';

/// Get data from the server using HTTP GET request and receive response as JSON
class GetData {
  GetData();

  get data => _data;
  get status => _status;

  late dynamic _data;
  late int _status;
  final String _url = Configuration.apiUri;

  Future<void> loadUsersORGuest({required bool isGuest, required int adminId, int? page, int? limit}) async {
    try {
      String uri = isGuest ? '$_url/guestList?admin=$adminId' : '$_url/userList?admin=$adminId';
      if (page != null) {
        uri += '&page=$page';
      }
      if (limit != null) {
        uri += '&per_page=$limit';
      }
      Response response = await get(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
          "Access-Control-Allow-Origin": _url,
        },
      ).timeout(const Duration(seconds: Configuration.timeout));
      _data = jsonDecode(response.body);
      _status = response.statusCode;
    } on TimeoutException {
      _data = {'status': 408, 'message': 'Request timed out! Try again'};
      _status = 408;
    } on SocketException {
      _data = {'status': 503, 'message': 'No internet connection!'};
      _status = 503;
    } on Exception {
      _data = {'status': 500, 'message': 'An error occurred! Try again'};
      _status = 500;
    }
  }

}
