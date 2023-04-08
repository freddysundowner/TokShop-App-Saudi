import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../controllers/checkout_controller.dart';
import '../models/checkout.dart';
import '../utils/utils.dart';
import 'client.dart';
import 'end_points.dart';

class OrderApi {
  static checkOut(var order, String productId) async {
    Get.find<CheckOutController>().msg.value = "";
    var responsecheck = await DbBase().databaseRequest(
        singleproductqtycheck + productId, DbBase().postRequestType,
        body: {"productId": productId, "quantity": order["quantity"]});
    print(responsecheck);
    var data = jsonDecode(responsecheck);

    if (data["status"] == true) {
      var response = await DbBase().databaseRequest(
          "$orders/${FirebaseAuth.instance.currentUser!.uid}",
          DbBase().postRequestType,
          body: {
            "order": [order]
          });

      return jsonDecode(response);
    } else {
      Get.find<CheckOutController>().msg.value = "Not in stock";

      return data;
    }
  }

  Future updateOrder(Map<String, dynamic> body, String id) async {
    try {
      var orderResponse = await DbBase().databaseRequest(
          updateOrders + id, DbBase().patchRequestType,
          body: body);
      printOut("orderResponse $orderResponse");
    } catch (e) {
      printOut("Error updateOrder  $e");
    }
  }

  cancelAnOrder(String orderId) async {
    try {
      var orderResponse = await DbBase()
          .databaseRequest(cancelOrders + orderId, DbBase().patchRequestType);

      printOut("cancelOrder $orderResponse");
    } catch (e) {
      printOut("Error cancelOrder  $e");
    }
  }

  finishAnOrder(String orderId) async {
    try {
      var orderResponse = await DbBase()
          .databaseRequest(finishOrders + orderId, DbBase().patchRequestType);

      printOut("finishAnOrder $orderResponse");
    } catch (e, s) {
      printOut("Error finishAnOrder  $e $s");
    }
  }
}
