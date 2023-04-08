import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/products/components/expandable_text.dart';
import 'package:tokshop/screens/products/components/product_size.dart';
import 'package:tokshop/screens/profile/profile_all_products.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/add_favorite.dart';

import '../../../utils/text.dart';
import '../../../utils/utils.dart';

class ProductDescription extends StatelessWidget {
  ProductDescription({
    Key? key,
    required this.product,
  }) : super(key: key);
  final ProductController productController = Get.find<ProductController>();
  final CheckOutController checkOutController = Get.find<CheckOutController>();

  final Product product;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name!,
              style: const TextStyle(
                fontSize: 21,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RatingBarIndicator(
                    rating: product.getReviewsAverage(),
                    itemCount: 5,
                    itemSize: 10.0,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    product.reviews!.length.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      await addToFavorite(context, product);
                    },
                    child: Obx(
                      () => Icon(
                        Ionicons.heart,
                        color: Get.find<WishListController>()
                                    .products
                                    .indexWhere((e) => e.id == product.id) !=
                                -1
                            ? kPrimaryColor
                            : Styles.neutralGrey,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      DynamicLinkService()
                          .generateShareLink(product.id!,
                              type: "product",
                              title: product.name,
                              msg: product.description,
                              imageurl: product.images![0])
                          .then((value) async {
                        await Share.share(value);
                      }).then((value) => Get.back());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.share,
                        size: 18,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          if (product.discountedPrice! > 0)
            SizedBox(
              height: getProportionateScreenHeight(64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: product.discountedPrice == 0
                        ? Text("${product.htmlPrice(product.price)}   ",
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ))
                        : Text.rich(
                            TextSpan(
                              text:
                                  "${product.htmlPrice(product.discountedPrice)}   ",
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                              children: [
                                TextSpan(
                                  text: "\n${product.htmlPrice(product.price)}",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: kTextColor,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/Discount.svg",
                          color: kPrimaryColor,
                        ),
                        Center(
                          child: Text(
                            "${product.calculatePercentageDiscount()}%\nOff",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: getProportionateScreenHeight(15),
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Text.rich(
            TextSpan(
              text: "$availability: ",
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primarycolor),
              children: [
                TextSpan(
                  text: product.quantity! > 0
                      ? "$in_stock (${product.quantity})"
                      : out_of_stock,
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: kPrimaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ExpandableText(
            title: description,
            content: product.description!,
          ),
          const SizedBox(height: 16),
          const Text(
            variations,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ProductSize(
            productSizes: product.variations!,
            onSelected: (size) {
              printOut(size);
              checkOutController.selectetedvariationvalue.value = size;
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              userController.getUserProfile(product.ownerId!.id!);
              Get.to(UserProfile());
            },
            child: Text.rich(
              TextSpan(
                text: sold_by,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: product.shopId!.name!.isEmpty
                        ? product.ownerId!.firstName!
                        : product.shopId!.name,
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
