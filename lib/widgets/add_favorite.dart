import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/services/user_api.dart';

addToFavorite(BuildContext context, Product product) async {
  WishListController favoriteController = Get.find<WishListController>();
  if (favoriteController.products
          .indexWhere((element) => element.id == product.id) !=
      -1) {
    favoriteController.products
        .removeWhere((element) => element.id == product.id);
    UserAPI.deleteFromFavorite(product.id!);
  } else {
    favoriteController.products.add(product);

    UserAPI.saveFovite(product.id!);
  }
}
