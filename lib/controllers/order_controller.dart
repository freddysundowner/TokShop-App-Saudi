import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:tokshop/models/Review.dart';
import 'package:tokshop/services/product_api.dart';

import '../models/order.dart';

class OrderController extends GetxController {
  var currentOrder = Order().obs;
  var currentOrderLoading = false.obs;
  var tabIndex = 0.obs;
  var loadingReview = false.obs;
  Rxn<Review> curentProductUserReview = Rxn(null);
  TextEditingController review = TextEditingController();

  var ratingvalue = 0.obs;
  var ratingError = "".obs;

  getProductReviewWithID(String productId) async {
    loadingReview.value = true;
    var response = await ProductPI().getProductReviewWithID(
        productId, FirebaseAuth.instance.currentUser!.uid);
    if (response["data"].length > 0) {
      curentProductUserReview.value = Review.fromMap(response["data"][0]);
    } else {
      curentProductUserReview.value = null;
    }
    curentProductUserReview.refresh();
    loadingReview.value = false;
  }

  addProductReview(String productId, String review, int rating) async {
    loadingReview.value = true;
    var response =
        await ProductPI().addProductReview(productId, review, rating);

    getProductReviewWithID(productId);
    loadingReview.value = false;
  }
}
