import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import 'client.dart';

class Api {
  static var client = http.Client();
  static callApi(
      {required String method, body, required String endpoint}) async {
    // _tryConnection();

    var url = Uri.parse(endpoint);
    if (method == DbBase().getRequestType) {
      return _callGet(url: url);
    }
    if (method == DbBase().postRequestType) {
      return _callPost(body: body!, url: url);
    }
    if (method == DbBase().patchRequestType) {
      return _callPut(body: body!, url: url);
    }
  }

  static _callGet({required Uri url}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      Map<String, String> headers = {};

      if (token != null) {
        headers = {'Authorization': "Bearer $token"};
      } else {
        AuthController().signOut();
      }
      final response = await client.get(url, headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  static _callPost({Map<String, dynamic>? body, required Uri url}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      Map<String, String> headers = {};
      if (token != null) {
        headers = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token"
        };
      }
      final response =
          await client.post(url, body: jsonEncode(body), headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  static _callPut({Map<String, dynamic>? body, required Uri url}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      Map<String, String> headers = {};
      if (token != null) {
        headers = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $token"
        };
      }
      final response =
          await client.put(url, body: jsonEncode(body), headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }
}
