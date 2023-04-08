import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/payments/payout_settings.dart';
import 'package:tokshop/screens/products/edit_product/edit_product_screen.dart';
import 'package:tokshop/screens/shops/apply_to_sell.dart';
import 'package:tokshop/utils/text.dart';
import 'package:tokshop/widgets/single_product_item.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../services/shop_api.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ProfileProducts extends StatelessWidget {
  String? userid;
  final ShopController shopController = Get.find<ShopController>();
  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();

  ProfileProducts({Key? key, this.userid}) : super(key: key) {
    getProducts();
  }

  getProducts() async {
    productController.selectedInterest.value = null;
    productController.selectedChannel.value = null;
    await productController.getAllroducts(userid: userid!);
  }

  final String closeShopIcon = "assets/icons/close_shop.png";
  final String openShopIcon = "assets/icons/open_shop.png";
  final String shopClosedIcon = "assets/icons/shop_closed.png";

  Future<void> refreshPage() {
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(listings),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Obx(() {
            if (productController.loading.value == true) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primarycolor,
                ),
              );
            }

            return productController.products.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: productController.products.length,
                    itemBuilder: (context, index) {
                      return SingleproductItem(
                        element: productController.products[index],
                        imageHeight: 180,
                        action: true,
                      );
                    },
                  )
                : const Center(
                    child: Text(
                    we_are_taking_some_cool_pictures,
                    style:
                        TextStyle(color: Styles.dullGreyColor, fontSize: 15.0),
                    textAlign: TextAlign.center,
                  ));
          }),
        ),
        floatingActionButton: userid == FirebaseAuth.instance.currentUser?.uid
            ? FloatingActionButton(
                backgroundColor: Styles.greenTheme.withOpacity(0.7),
                elevation: 4,
                hoverColor: Colors.green,
                splashColor: Colors.green,
                onPressed: () async {
                  addProduct(context);
                },
                child: const Icon(Icons.add),
              )
            : Container());
  }

  Future<void> updateShopPaymentOptions(List<String> paymentOptions) async {
    await BrandApi.updateShop({"paymentOptions": paymentOptions},
        authController.currentuser!.shopId!.id!);
  }

  void addProduct(BuildContext context) {
    if (authController.currentuser!.shopId == null) {
      Get.to(() => ApplyToSell());
      return;
    }
    if (authController.currentuser!.shopId?.open == true) {
      if (authController.usermodel.value!.payoutMethod != null &&
          shopController.currentShop.value.id ==
              authController.usermodel.value!.shopId!.id) {
        Get.to(() => const EditProductScreen());
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(no_payout_menu),
              content: const Text(set_payment_method),
              actions: [
                TextButton(
                  child: const Text(setup),
                  onPressed: () async {
                    Navigator.pop(context, false);
                    Get.to(() => PayoutSettings());
                  },
                ),
                TextButton(
                  child: const Text(no_now),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      Get.defaultDialog(
          title: shop_is_closed, middleText: you_cant_add_a_product);
    }
  }

  Future<void> openOrCloseShop(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(confirmation),
          content: Text(shopController.currentShop.value.open == true
              ? sure_you_want_to_close
              : sure_you_want_to_open),
          actions: [
            TextButton(
              child: const Text(yes),
              onPressed: () async {
                try {
                  shopController.currentShop.value.open =
                      !shopController.currentShop.value.open!;
                  shopController.currentShop.refresh();

                  if (shopController.currentShop.value.id ==
                      authController.usermodel.value!.shopId!.id) {
                    authController.usermodel.value!.shopId!.open =
                        shopController.currentShop.value.open!;
                    authController.usermodel.refresh();
                  }

                  var response = BrandApi.updateShop(
                      {"open": shopController.currentShop.value.open},
                      shopController.currentShop.value.id!);

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AsyncProgressDialog(
                        response,
                        message: Text(
                            shopController.currentShop.value.open == false
                                ? closing_shop
                                : opening_shop),
                        onError: (e) {},
                      );
                    },
                  );
                } finally {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        shopController.currentShop.value.open == false
                            ? shop_closed_successfully
                            : shop_opened_successfully,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: kPrimaryColor,
                    ),
                  );
                  Navigator.pop(context, false);
                  shopController.currentShop.refresh();
                  getProducts();
                }
              },
            ),
            TextButton(
              child: const Text(no),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }
}
