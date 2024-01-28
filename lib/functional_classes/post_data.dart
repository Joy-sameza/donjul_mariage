import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:marriage_app/config/config.dart';

/// Send data to server
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
          "Access-Control-Allow-Origin": "*"
        },
        body: dataBody,
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: Configuration.timeout));
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
      Response response = await get(
        Uri.parse('$_url/isVerified'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          "accept-encoding": "gzip, deflate, br",
          "Access-Control-Allow-Origin": "*"
        },
      );
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
          },
          body: jsonEncode({
            'data': token,
          }));
      var result = jsonDecode(response.body) as Map<String, dynamic>;
      result['status'] = response.statusCode;
      return result;
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
      "accept-encoding": "gzip, deflate, br",
      "Access-Control-Allow-Origin": "*"
    };
    String dataBody = jsonEncode(body);

    try {
      Response response = await post(
        Uri.parse('$url/$relativePath'),
        headers: headers,
        body: dataBody,
        encoding: Encoding.getByName('utf-8'),
      ).timeout(const Duration(seconds: Configuration.timeout));
      var res = jsonDecode(response.body) as Map<String, dynamic>;
      res['status'] = response.statusCode;
      instance.data = res;
    } on TimeoutException catch (e) {
      instance.data = {
        'status': 408,
        'message': 'Request timed out!'
      };
      if (kDebugMode) {
        print({"err": e.toString()});
      }
    } on Exception catch (e) {
      instance.data = {
        'status': 500,
        'message': 'An error occurred! Try again'
      };
      if (kDebugMode) {
        print({"err": e.toString()});
      }
    }

    if (kDebugMode) {
      print(instance.data);
    }
    return instance;
  }
}
