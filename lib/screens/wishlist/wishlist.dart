import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/products/components/product_list_single_item.dart';

import '../../controllers/checkout_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/global.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/product.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class Wishlist extends StatelessWidget {
  CheckOutController checkOutController = Get.find<CheckOutController>();
  WishListController favproductController = Get.find<WishListController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  final GlobalController _global = Get.find<GlobalController>();

  Wishlist({Key? key}) : super(key: key);

  Future<void> refreshPage() {
    return Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    return WillPopScope(
      onWillPop: () async {
        _global.tabPosition.value = 0;
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down_outlined,
                color: primarycolor,
                size: 35,
              ),
              onPressed: () {
                Get.back();
              },
            ),
            title: const Text(
              my_wishlist,
            ),
            centerTitle: true,
          ),
          body: FadedScaleAnimation(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.3.sm),
                    child: GetX<UserController>(
                      initState: (_) async {
                        favproductController.products.value =
                            await WishListController().getFavoriteProducts();
                      },
                      builder: (_) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                favproductController.products.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: const BouncingScrollPhysics(),
                                        padding: const EdgeInsets.all(8),
                                        itemCount: favproductController
                                            .products.length,
                                        itemBuilder: (context, index) {
                                          Product product = favproductController
                                              .products[index];
                                          return ProductListSingleItem(
                                              product: product,
                                              from: "wishlist");
                                        })
                                    : SizedBox(
                                        height: 0.5.sh,
                                        child: Center(
                                            child: Text(
                                              your_wishlist_is_empty,
                                          style: TextStyle(
                                              color: Styles.dullGreyColor,
                                              fontSize: 16.sp),
                                        )),
                                      ),
                                SizedBox(height: 0.02.sh),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
