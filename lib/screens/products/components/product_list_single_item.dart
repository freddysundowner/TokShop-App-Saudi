import 'package:agora_rtm/agora_rtm.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/screens/checkout/checkout_screen.dart';
import 'package:tokshop/screens/products/product_details.dart';

import '../../../utils/text.dart';
import '../../../utils/utils.dart';

class ProductListSingleItem extends StatelessWidget {
  Product product;
  String? from;
  AgoraRtmChannel? rtmChannel;
  ProductListSingleItem(
      {Key? key, required this.product, this.from, this.rtmChannel})
      : super(key: key);

  CheckOutController checkOutController = Get.find<CheckOutController>();
  TokShowController tokShowController = Get.find<TokShowController>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: from == "roompage" &&
              (tokShowController.currentRoom.value.id != null &&
                  FirebaseAuth.instance.currentUser!.uid ==
                      tokShowController.currentRoom.value.ownerId!.id)
          ? () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                    title: const Text(what_do_you_want_to_do),
                    actions: [
                      CupertinoActionSheetAction(
                        child:
                            const Text('Pin', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          Get.back();
                          Get.find<TokShowController>().pinProduct(product);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('Start Auction',
                            style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          Get.back();
                          Get.find<AuctionController>().addToAuction(product);
                        },
                      ),
                      CupertinoActionSheetAction(
                        child: const Text('Return to store',
                            style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          Get.back();
                          Get.find<TokShowController>().returnToStore(product);
                        },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: const Text(
                        'Cancel',
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
              );
            }
          : () {
              Get.to(ProductDetails(product: product));
            },
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  height: 70,
                  width: 60,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: Styles.textButton,
                      borderRadius: BorderRadius.circular(3)),
                  child: product.images!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images![0],
                          height: 250,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(imageplaceholder)),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      product.name!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          product.discountedPrice! > 0
                              ? product.htmlPrice(product.discountedPrice)
                              : product.htmlPrice(product.price),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        if (product.discountedPrice! > 0)
                          Text(
                            product.htmlPrice(product.price),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Styles.neutralGrey3),
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              from != null && from == "wishlist"
                  ? InkWell(
                      onTap: () async {
                        Get.find<WishListController>()
                            .products
                            .removeWhere((element) => product.id == element.id);
                        Get.find<WishListController>().products.refresh();

                        await Get.find<WishListController>()
                            .deleteFavorite(product.id!);
                        showSnackBack(Get.context!,removed_from_wishlist,
                            color: Colors.red);
                      },
                      child: const Text(
                        "Remove️",
                        style: TextStyle(fontSize: 14, color: kPrimaryColor),
                      ),
                    )
                  : Get.find<TokShowController>().currentRoom.value.id !=
                              null &&
                          FirebaseAuth.instance.currentUser!.uid ==
                              Get.find<TokShowController>()
                                  .currentRoom
                                  .value
                                  .ownerId!
                                  .id
                      ? InkWell(
                          child: const Icon(Icons.more_vert),
                          onTap: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                      title:
                                          const Text(what_do_you_want_to_do),
                                      actions: [
                                        CupertinoActionSheetAction(
                                          child: const Text('Pin',
                                              style: TextStyle(fontSize: 16)),
                                          onPressed: () {
                                            Get.back();
                                            Get.find<TokShowController>()
                                                .pinProduct(product);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: const Text('Start Auction',
                                              style: TextStyle(fontSize: 16)),
                                          onPressed: () {
                                            Get.back();
                                            Get.find<AuctionController>()
                                                .addToAuction(product);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: const Text('Return to store',
                                              style: TextStyle(fontSize: 16)),
                                          onPressed: () {
                                            Get.back();
                                            Get.find<TokShowController>()
                                                .returnToStore(product);
                                          },
                                        ),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: const Text(
                                          'Cancel',
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )),
                            );
                          },
                        )
                      : FirebaseAuth.instance.currentUser!.uid ==
                              product.ownerId!.id
                          ? InkWell(
                              onTap: () async {
                                tokShowController.createRoomView(
                                    title: product.name!, product: product);
                              },
                              child: Container(
                                width: MediaQuery.of(Get.context!).size.width *
                                    0.40,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      go_live,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.sp),
                                    ),
                                    const Icon(
                                      Icons.add,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : InkWell(
                              child: const Icon(
                                Icons.add_shopping_cart_outlined,
                                color: kPrimaryColor,
                              ),
                              onTap: () {
                                checkOutController.product.value = product;
                                checkOutController.qty.value = 1;
                                if (checkOutController
                                            .selectetedvariationvalue.value ==
                                        "" &&
                                    product.variations!.isNotEmpty) {
                                  checkOutController.selectetedvariationvalue
                                      .value = product.variations![0];
                                }
                                Get.to(() => CheckOut());
                              },
                            )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
