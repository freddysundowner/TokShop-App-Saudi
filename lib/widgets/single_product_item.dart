import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/products/edit_product/edit_product_screen.dart';
import 'package:tokshop/screens/products/product_details.dart';
import 'package:tokshop/services/product_api.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/add_favorite.dart';
import 'package:tokshop/widgets/product_image.dart';

import '../utils/text.dart';
import '../utils/utils.dart';

class SingleproductItem extends StatelessWidget {
  Product element;
  double? imageHeight;
  double? width;
  Function? callBack;
  bool? action = true;
  SingleproductItem({
    Key? key,
    required this.element,
    this.width,
    this.imageHeight,
    this.action,
    this.callBack,
  }) : super(key: key);
  final ProductController productController = Get.find<ProductController>();

  WishListController favoriteController = Get.find<WishListController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: callBack != null
            ? () => callBack!()
            : () {
                Get.to(ProductDetails(
                  product: element,
                ));
              },
        child: SizedBox(
          width: width != null ? getProportionateScreenWidth(width!) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ProductImage(
                    element: element.images!.isEmpty ? "" : element.images![0],
                    size: imageHeight ?? 250,
                  ),
                  if (element.discountedPrice! > 0 &&
                      (((element.price! - element.discountedPrice!) /
                                  element.price!) *
                              100) >
                          0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                            )),
                        child: Text(
                          "-${(((element.price! - element.discountedPrice!) / element.price!) * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    child: InkWell(
                      onTap: () async {
                        await addToFavorite(context, element);
                      },
                      child: Obx(
                        () => Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Ionicons.heart,
                            color: favoriteController.products.indexWhere(
                                        (e) => e.id == element.id) !=
                                    -1
                                ? kPrimaryColor
                                : Styles.neutralGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (element.ownerId?.id ==
                      FirebaseAuth.instance.currentUser!.uid)
                    Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (action == true) {
                                  final confirmation =
                                      await showConfirmationDialog(Get.context!,
                                          are_you_sure_you_want_to_delete_product);
                                  if (await confirmation) {
                                    for (int i = 0;
                                        i < element.images!.length;
                                        i++) {
                                      FirebaseStorage.instance
                                          .refFromURL(element.images![i])
                                          .delete();
                                    }

                                    bool productInfoDeleted = false;

                                    var deleteProduct =
                                        await ProductPI.updateProduct(
                                            {"deleted": true}, element.id!);
                                    productInfoDeleted =
                                        deleteProduct["success"];

                                    productController.profileproducts
                                        .removeWhere(
                                            (e) => e.id == element.id!);
                                    productController.profileproducts.refresh();

                                    String snackbarMessage = "";
                                    try {
                                      if (productInfoDeleted == true) {
                                        snackbarMessage =
                                            product_deleted_successfully;
                                      } else {
                                        throw "Couldn't delete product, please retry";
                                      }
                                    } catch (e) {
                                      snackbarMessage = e.toString();
                                    } finally {
                                      GetSnackBar(
                                        messageText: Text(
                                          snackbarMessage,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: kPrimaryColor,
                                      );
                                    }
                                  }
                                } else {
                                  productController.profileproducts
                                      .removeWhere((e) => e.id == element.id!);
                                  productController.profileproducts.refresh();
                                }
                              },
                              child: const Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            if (action == true)
                              InkWell(
                                  onTap: () async {
                                    final confirmation =
                                        await showConfirmationDialog(
                                            Get.context!,
                                            are_you_sure_to_edit_product);
                                    if (confirmation) {
                                      productController.product = element;
                                      productController.selectedImages
                                          .assignAll(productController
                                              .product.images!
                                              .map((e) => CustomImage(
                                                  imgType: ImageType.network,
                                                  path: e))
                                              .toList());

                                      Get.to(() => EditProductScreen(
                                            product: element,
                                          ));
                                    }
                                    // await refreshPage();
                                  },
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                  )),
                          ],
                        ),
                      ),
                    )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  element.name!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Text(
                    element.discountedPrice! > 0
                        ? element.htmlPrice(element.discountedPrice)
                        : element.htmlPrice(element.price),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w200),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  if (element.discountedPrice! > 0)
                    Text(
                      element.htmlPrice(element.price),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Styles.neutralGrey3),
                    )
                ],
              ),
              if (element.quantity == 0)
                const Text(
                  out_of_stock,
                  style: TextStyle(fontSize: 12, color: kPrimaryColor),
                ),
              if (element.quantity! > 0)
                const Text(
                  in_stock,
                  style: TextStyle(fontSize: 12, color: Styles.greenTheme),
                ),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: element.getReviewsAverage(),
                    itemCount: 5,
                    itemSize: 10.0,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    element.reviews!.length.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
