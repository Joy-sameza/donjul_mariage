import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:marriage_app/config/config.dart';

/// Send data to server using HTTP POST request and receive response as JSON
class PostData {
  PostData(
      {required this.username,
      required this.password,
      this.telephone,
      this.authToken,
      this.actualName,
      this.adminReference});

  late String username, password;
  String? telephone, authToken, actualName, adminReference;
  final String _url = Configuration.apiUri;
  late Map<String, dynamic> data;
  static const timeoutDelay = Duration(seconds: Configuration.timeout);

  Future<Map<String, dynamic>> postData({required String relativePath}) async {
    var body = {
      'username': username,
      'password': password,
      'telephone': telephone ?? '',
      'actual_name': actualName ?? '',
    };
    var dataBody = jsonEncode(body);
    try {
      Response response = await post(
        Uri.parse('$_url/$relativePath'),
        headers: {
          'Content-Type': 'application/json',
          "Access-Control-Allow-Origin": _url
        },
        body: dataBody,
      ).timeout(timeoutDelay);
      var r = jsonDecode(response.body) as Map<String, dynamic>;
      r['status'] = response.statusCode;
      if (kDebugMode) {
        print(r);
      }
      return r;
    } on Exception catch (e) {
      if (kDebugMode) {
        print(dataBody);
        print(e);
      }
      if (e is TimeoutException) {
        return {'status': 408, 'message': 'Request timed out!'};
      }
      return {'status': 500, 'message': 'An error occurred! Try again'};
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
        "accept-encoding": "gzip, deflate, br",
        "Access-Control-Allow-Origin": _url
      };
      Response response = await get(
        Uri.parse('$_url/isVerified'),
        headers: headers,
      ).timeout(timeoutDelay);
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      result['status'] = response.statusCode;
      return result;
    } on Exception {
      return {'status': 500, 'message': 'An error occurred! Try again'};
    }
  }

  Future<Map<String, dynamic>> sendQRToken(String token) async {
    try {
      Response response = await post(Uri.parse('$_url/qrdecode'),
          headers: {
            'Content-Type': 'application/json',
            "Access-Control-Allow-Origin": _url
          },
          body: jsonEncode({
            'data': token,
          })).timeout(timeoutDelay);
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      result['status'] = response.statusCode;
      return result;
    } on TimeoutException {
      return {'status': 408, 'error': 'Request timed out!'};
    } on Exception {
      return {'status': 500, 'message': 'An error occurred! Try again'};
    }
  }

  factory PostData.addUser(
      {required String actualName,
      required String telephone,
      required int adminReference}) {
    return PostData(
      actualName: actualName,
      telephone: telephone,
      adminReference: '$adminReference',
      username: '',
      password: '',
    );
  }

  factory PostData.addAuthToken({required String authToken}) {
    return PostData(
      username: "",
      password: "",
      authToken: authToken,
    );
  }

  /// Submit data to server and return response from server and save the response into the instance
  static Future<PostData> submitData(
      {required String relativePath,
      String username = '',
      String password = '',
      String telephone = '',
      String authToken = '',
      String actualName = '',
      int adminReference = 0,
      String url = Configuration.apiUri}) async {
    PostData instance = PostData(
      username: username,
      password: password,
      telephone: telephone,
      authToken: authToken,
      actualName: actualName,
      adminReference: "$adminReference",
    );

    var body = {
      'username': instance.username,
      'password': instance.password,
      'telephone': instance.telephone,
      'actual_name': instance.actualName,
      'admin_id': instance.adminReference,
    };
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${instance.authToken ?? ''}',
      "Access-Control-Allow-Origin": Configuration.apiUri,
    };
    String dataBody = jsonEncode(body);

    try {
      Response response = await post(
        Uri.parse('$url/$relativePath'),
        headers: headers,
        body: dataBody,
        encoding: Encoding.getByName('utf-8'),
      ).timeout(timeoutDelay);
      var res = jsonDecode(response.body) as Map<String, dynamic>;
      if (kDebugMode) {
        print(res);
      }
      res['status'] = response.statusCode;
      instance.data = res;
    } on TimeoutException {
      instance.data = {'status': 408, 'error': 'Request timed out!'};
    } on Exception catch (e) {
      instance.data = {'status': 500, 'error': 'An error occurred! Try again'};
      if (kDebugMode) {
        print({"err": e.toString(), 's': instance.data['status']});
      }
    }

    return instance;
  }

  /// Submit data to server using patch request and return response from server and save the response into the instance
  static Future<PostData> patchData(
      {required String relativePath,
      String actualName = '',
      String telephone = '',
      int adminReference = 0,
      String url = Configuration.apiUri,
      required int userORGuestId}) async {
    PostData instance = PostData(
        username: '',
        password: '',
        actualName: actualName,
        telephone: telephone,
        adminReference: adminReference as String);

    Map<String, String?> body = {
      'telephone': instance.telephone,
      'actual_name': instance.actualName,
      'admin_id': instance.adminReference,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${instance.authToken ?? ''}',
      "Access-Control-Allow-Origin": Configuration.apiUri,
    };
    String dataBody = jsonEncode(body);

    try {
      Response response = await patch(
              Uri.parse("$url/$relativePath/$userORGuestId"),
              headers: headers,
              body: dataBody)
          .timeout(timeoutDelay);
      var res = jsonDecode(response.body) as Map<String, dynamic>;
      res['status'] = response.statusCode;
      instance.data = res;
    } on TimeoutException {
      instance.data = {'status': 408, 'error': 'Request timed out!'};
    } on Exception catch (e) {
      instance.data = {'status': 500, 'error': 'An error occurred! Try again'};
      if (kDebugMode) {
        print({"err": e.toString(), 's': instance.data['status']});
      }
    }

    return instance;
  }
}
