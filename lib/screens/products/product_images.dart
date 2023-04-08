import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/controllers/product_image_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/services/product_api.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/add_favorite.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';
import 'package:tokshop/widgets/product_image.dart';

import '../../utils/text.dart';
import '../../utils/utils.dart';

class ProductImages extends StatelessWidget {
  ProductImages({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  ProductImageSwiper productController = Get.put(ProductImageSwiper());
  WishListController favoriteController = Get.find<WishListController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              child: SizedBox(
                height: SizeConfig.screenHeight! * 0.35,
                child: product.images!.isNotEmpty
                    ? Obx(
                        () => CachedNetworkImage(
                          imageUrl: product
                              .images![productController.currentImageIndex],
                          fit: BoxFit.cover,
                          width: SizeConfig.screenWidth!,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          imageplaceholder,
                          height: SizeConfig.screenHeight! * 0.35,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.05),
                ],
              )),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: InkWell(
                child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.clear,
                    )),
                onTap: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              product.images!.length,
              (index) => buildSmallPreview(productController, index: index),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSmallPreview(ProductImageSwiper productImagesSwiper,
      {required int index}) {
    return GestureDetector(
      onTap: () {
        productImagesSwiper.currentImageIndex = index;
      },
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(8)),
        height: getProportionateScreenWidth(40),
        width: getProportionateScreenWidth(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
              color: productImagesSwiper.currentImageIndex == index
                  ? kPrimaryColor
                  : Colors.transparent),
        ),
        child: product.images!.length > 30
            ? ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.asset(imageplaceholder)),
                  ),
                  filterQuality: FilterQuality.high,
                  height: 60,
                  width: 60,
                  imageUrl:
                      product.images![productImagesSwiper.currentImageIndex],
                  fit: BoxFit.cover,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.asset(
                  imageplaceholder,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
