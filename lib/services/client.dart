import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/utils.dart';

class DbBase {
  var postRequestType = "POST";
  var getRequestType = "GET";
  var patchRequestType = "PUT";
  var deleteRequestType = "DELETE";

  databaseRequest(String link, String type,
      {Map<String, dynamic>? body,
      Map<String, String>? bodyFields,
      Map<String, String>? headers}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");

      headers ??= {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${token ?? ""}"
      };
      print(type);
      var request = http.Request(type, Uri.parse(link));
      if (body != null) {
        request.body = json.encode(body);
      }

      if (bodyFields != null) {
        request.bodyFields = bodyFields;
      }
      print(link);

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      return response.stream.bytesToString();
    } catch (e, s) {
      printOut("Error on api $link $e $s");
    }
  }
}
