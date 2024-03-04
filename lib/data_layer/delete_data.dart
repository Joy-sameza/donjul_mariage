import 'dart:convert';

import 'package:http/http.dart';
import 'package:marriage_app/config/config.dart';

class DeleteData {
  const DeleteData({required this.adminId, required this.userId});

  final int adminId;
  final int userId;
  final String _url = Configuration.apiUri;

  Future<Map<String, dynamic>> deleteData(
      {required String relativePath}) async {
    var uri = '$_url/$relativePath?adminId=$adminId&userId=$userId';
    var requestUri = Uri.parse(uri);
    print(requestUri.toString());
    try {
      Response response = await delete(
        requestUri,
        headers: {
          'Content-Type': 'application/json',
          "Access-Control-Allow-Origin": _url,
        },
      );
      var r = jsonDecode(response.body) as Map<String, dynamic>;
      r['status'] = response.statusCode;
      return r;
    } on Exception catch (e) {
      print(e.toString());
      return {'status': 500, 'message': 'An error occurred! Try again'};
    }
  }
}
