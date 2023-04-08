import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/global.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/shop.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/home/home_page.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/services/shop_api.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/follow_button.dart';
import 'package:tokshop/widgets/nothingtoshow_container.dart';
import 'package:tokshop/widgets/product_chime.dart';
import 'package:tokshop/widgets/product_image.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../utils/text.dart';

class AllBrands extends StatelessWidget {
  AllBrands({Key? key}) : super(key: key);
  ShopController shopController = Get.find<ShopController>();
  final GlobalController globalController = Get.find<GlobalController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (shopController.searchEnabled.isFalse) const Text(all_brands),
              if (shopController.searchEnabled.isTrue)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: CustomTextFormField(
                      hint: search_by_name,
                      onChanged: (String c) async {
                        globalController.searchShopController.text = c;
                        if (c.isNotEmpty) {
                          shopController.isSearchingShop.value = true;
                          globalController.searchPageNumber.value = 1;
                          globalController.searchoption.value = "shops";
                          await globalController.search();
                          shopController.allBrandsList.value = globalController
                              .searchresults
                              .map((element) => Brand.fromJson(element))
                              .toList();
                          shopController.isSearchingShop.value = false;
                        } else {
                          await shopController.getBrands();
                        }
                      },
                    ),
                  ),
                ),
              if (shopController.searchEnabled.isFalse)
                InkWell(
                  child: const Icon(Icons.search_rounded),
                  onTap: () {
                    shopController.searchEnabled.value =
                        !shopController.searchEnabled.value;
                  },
                ),
              if (shopController.searchEnabled.isTrue)
                InkWell(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    shopController.searchEnabled.value =
                        !shopController.searchEnabled.value;
                  },
                )
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return shopController.getBrands();
        },
        child: Obx(
          () => shopController.isSearchingShop.isTrue
              ? const SizedBox(
                  height: 280,
                  child: ListViewChime(),
                )
              : shopController.allBrandsList.isEmpty
                  ? const NothingToShowContainer(
                      secondaryMessage: no_shops_found,
                    )
                  : ListView(
                      controller: shopController.shopCustomScroll(),
                      padding: const EdgeInsets.all(8),
                      children: shopController.allBrandsList
                          .map((shop) => InkWell(
                                onTap: () {
                                  shopController.currentShop.value = shop;
                                  if (FirebaseAuth.instance.currentUser!.uid ==
                                      shop.ownerId!.id!) {
                                    userController.getUserProfile(
                                        FirebaseAuth.instance.currentUser!.uid);
                                    Get.find<GlobalController>()
                                        .tabPosition
                                        .value = 3;
                                    Get.back();
                                  } else {
                                    userController
                                        .getUserProfile(shop.ownerId!.id!);
                                    Get.to(UserProfile());
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    children: [
                                      ProductImage(
                                        element: shop.image!,
                                        size: 100,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shop.name!,
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${shop.ownerId!.followers.length} $followers",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: primarycolor),
                                                ),
                                                const Spacer(),
                                                FollowUnfollowButton(
                                                  height: 30,
                                                  callBack: () {
                                                    if (shop.ownerId!.followers
                                                            .indexWhere((element) =>
                                                                element.id ==
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid) ==
                                                        -1) {
                                                      shop.ownerId!.followers
                                                          .add(authController
                                                              .usermodel
                                                              .value!);
                                                      shopController
                                                          .allBrandsList
                                                          .refresh();
                                                      UserAPI().followAUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          shop.ownerId!.id!);
                                                    } else {
                                                      shop.ownerId!.followers
                                                          .removeWhere(
                                                              (element) =>
                                                                  element.id ==
                                                                  authController
                                                                      .usermodel
                                                                      .value!
                                                                      .id);
                                                      shopController
                                                          .allBrandsList
                                                          .refresh();
                                                      UserAPI().unFollowAUser(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          shop.ownerId!.id!);
                                                    }
                                                  },
                                                  enabled: shop
                                                          .ownerId!.followers
                                                          .indexWhere((element) =>
                                                              element.id ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) ==
                                                      -1,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
        ),
      ),
    );
  }
}
