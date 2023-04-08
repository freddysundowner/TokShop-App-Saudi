import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/screens/menu/settings.dart';
import 'package:tokshop/screens/menu/shipping_address.dart';
import 'package:tokshop/screens/orders/orders.dart';
import 'package:tokshop/screens/orders/purchases.dart';
import 'package:tokshop/screens/profile/profile_all_products.dart';
import 'package:tokshop/screens/wallet/wallet_page.dart';
import 'package:tokshop/screens/wishlist/wishlist.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../main.dart';
import '../../services/dynamic_link_services.dart';
import '../../services/shop_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class MenuPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  final ShopController shopController = Get.find<ShopController>();

  final String socialLinkError = '';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController twitterController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();

  MenuPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    userController.gettingMyAddrresses();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          menu,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20.0,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                buyer,
                style: TextStyle(
                    fontSize: 18.0.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              _itemRow(purchases, () {
                Get.to(() => Purchases());
              }, iconData: Icons.receipt),
              _itemRow(payment, () {
                purchaseInfo();
              }, icon: "card.png"),
              _itemRow(wishlist, () {
                Get.to(() => Wishlist());
              }, iconData: Icons.favorite),
              Text(
                seller,
                style: TextStyle(
                    fontSize: 18.0.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              _itemRow(orders, () {
                Get.to(() => Orders());
              }, iconData: Icons.receipt),
              _itemRow(payouts, () {
                Get.to(() => WalletPage());
              }, svg: "Cash.svg"),
              _itemRow(listings, () {
                Get.to(() => ProfileProducts(
                      userid: FirebaseAuth.instance.currentUser!.uid,
                    ));
              }, iconData: Icons.list),
              _itemRow(import_products, () {
                showFilterBottomSheet(
                    context,
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 0.03.sh,
                          ),
                          Text(
                            import_products_from,
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w300),
                          ),
                          Theme(
                            data: ThemeData(
                              //here change to your color
                              unselectedWidgetColor: primarycolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 15),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Get.defaultDialog(
                                          title: "",
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                  child: Column(
                                                children: [
                                                  const Text(
                                                      what_do_you_want_to_do),
                                                  Text(
                                                    if_you_click_on_update,
                                                    style: TextStyle(
                                                        fontSize: 10.sp),
                                                  ),
                                                ],
                                              )),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Text(
                                                      cancel,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      Get.back();
                                                      Get.defaultDialog(
                                                          title:
                                                              "$updating_products...",
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          content:
                                                              const CircularProgressIndicator(),
                                                          barrierDismissible:
                                                              true);
                                                      await shopController
                                                          .importWcProducts(
                                                              type: "update");
                                                    },
                                                    child: const Text(
                                                      update,
                                                      style: TextStyle(
                                                          color: Styles.red),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      Get.back();
                                                      Get.defaultDialog(
                                                          title:
                                                              "$trying_to_import...",
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          content:
                                                              const CircularProgressIndicator(),
                                                          barrierDismissible:
                                                              true);
                                                      await shopController
                                                          .importWcProducts(
                                                              type: "import");
                                                    },
                                                    child: const Text(
                                                      import_new,
                                                      style: TextStyle(
                                                          color: Styles
                                                              .greenTheme),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          barrierDismissible: true);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                "assets/icons/woocommerce.png"),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  woocommerce,
                                                  style: TextStyle(
                                                      color: primarycolor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  you_can_only_import,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: kPrimaryColor
                                                  .withOpacity(0.30)),
                                          child: const Icon(
                                            Icons.navigate_next,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(color: Colors.grey),
                                  InkWell(
                                    onTap: () async {
                                      Get.defaultDialog(
                                          title: "",
                                          contentPadding:
                                              const EdgeInsets.all(10),
                                          content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                  child: Column(
                                                children: [
                                                  const Text(
                                                      what_do_you_want_to_do),
                                                  Text(
                                                    if_you_click_on_update,
                                                    style: TextStyle(
                                                        fontSize: 10.sp),
                                                  ),
                                                ],
                                              )),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Text(
                                                      cancel,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      Get.back();
                                                      Get.defaultDialog(
                                                          title:
                                                              "$updating_products...",
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          content:
                                                              const CircularProgressIndicator(),
                                                          barrierDismissible:
                                                              true);
                                                      await shopController
                                                          .importSpProducts(
                                                              type: "update");
                                                    },
                                                    child: const Text(
                                                      update,
                                                      style: TextStyle(
                                                          color: Styles.red),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      Get.back();
                                                      Get.defaultDialog(
                                                          title:
                                                              "$trying_to_import...",
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          content:
                                                              const CircularProgressIndicator(),
                                                          barrierDismissible:
                                                              true);
                                                      await shopController
                                                          .importSpProducts(
                                                              type: "import");
                                                    },
                                                    child: const Text(
                                                      import_new,
                                                      style: TextStyle(
                                                          color: Styles
                                                              .greenTheme),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          barrierDismissible: true);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                                "assets/icons/shopify.png"),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  shopify,
                                                  style: TextStyle(
                                                      color: primarycolor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  you_can_only_import,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: kPrimaryColor
                                                  .withOpacity(0.30)),
                                          child: const Icon(
                                            Icons.navigate_next,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              }, iconData: Icons.download_rounded),
              if (authController.usermodel.value?.shopId != null)
                _itemRow(close_shop, () async {
                  await openOrCloseShop(context);
                }, iconData: Icons.lock_clock, color: Colors.red),
              Text(
                account,
                style: TextStyle(
                    fontSize: 18.0.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              _itemRow(settings, () {
                Get.to(() => AccountSettings());
              }, iconData: Icons.settings),
              _itemRow(ship_address, () {
                Get.to(() => ShippingAddress());
              }, iconData: Icons.location_on),
              SizedBox(
                height: 0.01.sh,
              ),
              InkWell(
                onTap: () {
                  _homeController.shareSheetLoading.value = true;
                  DynamicLinkService()
                      .generateShareLink(
                          Get.find<AuthController>().usermodel.value!.id!,
                          type: "refer")
                      .then((value) async => await Share.share(value))
                      .then((value) =>
                          _homeController.shareSheetLoading.value = false);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 0.01.sh,
                    ),
                    Obx(() {
                      return _homeController.shareSheetLoading.isFalse
                          ? Text(
                              invite_friends,
                              style: TextStyle(fontSize: 14.sp),
                            )
                          : Transform.scale(
                              scaleX: 0.8,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: primarycolor,
                                ),
                              ));
                    }),
                    const Spacer(),
                    const Icon(
                      Icons.navigate_next,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 0.03.sh,
              ),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return logOutDialog();
                      });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    Text(log_out,
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 17.0.sp,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              SizedBox(
                height: 0.03.sh,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openOrCloseShop(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(confirmation),
          content: Text(authController.usermodel.value!.shopId!.open == true
              ? sure_you_want_to_close
              : sure_you_want_to_open),
          actions: [
            TextButton(
              child: const Text(yes),
              onPressed: () async {
                try {
                  authController.usermodel.value!.shopId!.open =
                      !authController.usermodel.value!.shopId!.open!;
                  authController.usermodel.refresh();

                  var response = BrandApi.updateShop(
                      {"open": authController.usermodel.value!.shopId!.open},
                      authController.usermodel.value!.shopId!.id!);

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AsyncProgressDialog(
                        response,
                        message: Text(
                            authController.usermodel.value!.shopId!.open ==
                                    false
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
                        authController.usermodel.value!.shopId!.open == false
                            ? shop_closed_successfully
                            : shop_opened_successfully,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: kPrimaryColor,
                    ),
                  );
                  Navigator.pop(context, false);
                  authController.usermodel.refresh();
                  // getProducts();
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

  _itemRow(String title, Function function,
      {String? icon,
      IconData? iconData,
      String? svg,
      Color color = Colors.black}) {
    return Column(
      children: [
        SizedBox(
          height: 0.01.sh,
        ),
        InkWell(
          onTap: () => function(),
          child: Row(
            children: [
              if (svg != null)
                SvgPicture.asset(
                  "assets/icons/$svg",
                  width: 25,
                  color: color,
                ),
              if (icon != null)
                Image.asset(
                  "assets/icons/$icon",
                  width: 25,
                  color: color,
                ),
              if (iconData != null)
                Icon(
                  iconData,
                  color: color,
                ),
              SizedBox(
                width: 0.01.sh,
              ),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 14.sp),
              ),
              const Spacer(),
              const Icon(
                Icons.navigate_next,
                color: Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0.01.sh,
        ),
        const Divider(
          color: Colors.grey,
        ),
        SizedBox(
          height: 0.01.sh,
        ),
      ],
    );
  }
}

logOutDialog() {
  return Dialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Container(
      height: 200,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.red,
              size: 45,
            ),
            const SizedBox(height: 19.0),
            Text(
              want_to_log_out,
              style: TextStyle(color: primarycolor, fontSize: 16.sp),
            ),
            const SizedBox(height: 19.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    Get.back();
                    Get.defaultDialog(
                        title: "$logging_out...",
                        contentPadding: const EdgeInsets.all(10),
                        content: const CircularProgressIndicator(),
                        barrierDismissible: false);
                    await authController.signOut();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    child: Text(
                      yes,
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    child: Text(
                      no,
                      style: TextStyle(
                          color: primarycolor, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ),
  );
}

Future<void> updateShopPaymentOptions(List<String> paymentOptions) async {
  await BrandApi.updateShop({"paymentOptions": paymentOptions},
      authController.currentuser!.shopId!.id!);
}
