import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/product.dart';

import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import 'api.dart';
import 'client.dart';
import 'end_points.dart';

class ProductPI {
  static updateProduct(
      Map<String, dynamic> productdata, String productid) async {
    var response = await Api.callApi(
        method: DbBase().patchRequestType,
        endpoint: products + productid,
        body: productdata);
    Get.find<ProductController>()
        .getAllroducts(userid: Get.find<AuthController>().usermodel.value!.id!);
    return response;
  }

  getUserProducts(String userId) async {
    var products = await DbBase()
        .databaseRequest(userProducts + userId, DbBase().getRequestType);
    return jsonDecode(products);
  }

  getProductById(String productId) async {
    var productres = await DbBase()
        .databaseRequest(updateproduct + productId, DbBase().getRequestType);
    return jsonDecode(productres);
  }

  static String getPathForProductImage(String id, int index) {
    String path = "products/images/$id";
    return "${path}_$index";
  }

  static saveProduct(Map<String, dynamic> productdata) async {
    var response = await DbBase().databaseRequest(
        product + Get.find<AuthController>().currentuser!.shopId!.id!,
        DbBase().postRequestType,
        body: productdata);
    return jsonDecode(response);
  }

  static getAllroducts(String page,
      {String title = "",
      String userid = "",
      String channel = "",
      String interest = "",
      String limit = "15",
      bool featured = false}) async {
    var respinse = await DbBase().databaseRequest(
        '$allproductspaginated?userid=$userid&page=$page&limit=$limit${title == "" ? "" : "&title=$title"}&featured=$featured&interest=$interest&channel=$channel',
        DbBase().getRequestType);
    return jsonDecode(respinse);
  }

  static updateProductsImages(String productId, List<dynamic> imgUrl) async {
    var respinse = await DbBase().databaseRequest(
        updateproductimages + productId, DbBase().patchRequestType,
        body: {"images": imgUrl});
    return jsonDecode(respinse);
  }

  static getCategories() async {
    var categories =
        await DbBase().databaseRequest(channels, DbBase().getRequestType);
    return jsonDecode(categories);
  }

  getProductReviewWithID(id, String uid) async {
    var reviews = await DbBase().databaseRequest(
        "${productreviews + uid}/$id", DbBase().getRequestType);
    return jsonDecode(reviews);
  }

  addProductReview(String id, String review, int rating) async {
    var reviews = await DbBase()
        .databaseRequest(productreviews + id, DbBase().postRequestType, body: {
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "rating": rating,
      "review": review,
    });
    return jsonDecode(reviews);
  }
}
