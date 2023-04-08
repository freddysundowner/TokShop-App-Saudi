import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/product.dart';
import '../services/user_api.dart';
import '../utils/functions.dart';

class WishListController extends GetxController {
  RxList<dynamic> products = RxList([]);
  var loading = false.obs;
  var favoritekey = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (FirebaseAuth.instance.currentUser != null) {
      getFavoriteProducts();
    }
  }

  Future<List> getFavoriteProducts() async {
    try {
      loading.value = true;
      var response = await UserAPI.getMyFavorites();
      favoritekey.value = response["_id"];
      List allproducts = response["productId"].map((e) {
        return Product.fromJson(e);
      }).toList();
      products.value = allproducts;
      loading.value = false;
      return allproducts;
    } catch (e) {
      printOut(e);
      return [];
    }
  }

  saveFavorite(String productId) async {
    var response = await UserAPI.saveFovite(productId);
    favoritekey.value = response["_id"];
  }

  deleteFavorite(String productId) async {
    await UserAPI.deleteFromFavorite(productId);
  }
}
