import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'api.dart';
import 'client.dart';
import 'end_points.dart';

class BrandApi {
  static saveShop(Map<String, dynamic> shopdata) async {
    var response = await await DbBase().databaseRequest(
        shop + FirebaseAuth.instance.currentUser!.uid, DbBase().postRequestType,
        body: shopdata);
    return jsonDecode(response);
  }

  static updateShop(Map<String, dynamic> shopdata, String shopid) async {
    var response = await DbBase().databaseRequest(
        updateshop + shopid, DbBase().patchRequestType,
        body: shopdata);
    return jsonDecode(response);
  }

  static getAllBrands(String page, {String title = ""}) async {
    var respinse = await DbBase().databaseRequest(
        '$popularshops?page=$page&limit=$limit${title == "" ? "" : "&title=$title"}',
        DbBase().getRequestType);
    return jsonDecode(respinse);
  }

  getShopById(String? shopId) async {
    var shops = await DbBase()
        .databaseRequest(updateshop + shopId!, DbBase().getRequestType);
    return jsonDecode(shops);
  }

  static String getPathForShop(String shopid) {
    return "shop/$shopid";
  }

  static getBanks(String country) async {
    var banks = await DbBase()
        .databaseRequest(flutterwaveBanks + country, DbBase().getRequestType);
    return jsonDecode(banks);
  }

  static createFlutterrWaveAccount(var data, String id) async {
    var banks = await DbBase().databaseRequest(
        "$flutterwave/$id", DbBase().postRequestType,
        body: data);
    return jsonDecode(banks);
  }

  static importWcProducts(String type) async {
    var response = await DbBase().databaseRequest(
        import, DbBase().postRequestType,
        body: {"userId": FirebaseAuth.instance.currentUser!.uid, "type": type});
    return jsonDecode(response);
  }

  static importSpProducts(String type) async {
    var response = await DbBase().databaseRequest(
        importsp, DbBase().postRequestType,
        body: {"userId": FirebaseAuth.instance.currentUser!.uid, "type": type});
    return jsonDecode(response);
  }

  static searchShop(String string, {required String title}) async {
    var response = await DbBase().databaseRequest(
      "$shop/search/$title/1",
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }
}
