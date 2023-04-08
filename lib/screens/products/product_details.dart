import 'package:animation_wrappers/Animations/faded_scale_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/products/components/expandable_text.dart';
import 'package:tokshop/screens/products/components/fab.dart';
import 'package:tokshop/screens/products/components/product_description.dart';
import 'package:tokshop/screens/products/components/product_reviews_card.dart';
import 'package:tokshop/screens/products/product_images.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/single_product_item.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../utils/text.dart';
import '../../utils/utils.dart';

class ProductDetails extends StatelessWidget {
  final Product product;
  ProductDetails({Key? key, required this.product}) : super(key: key);
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    productController.getProductById(product);
    productController.getRelatedProductByInterest(product);
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => productController.loadingSingleProduct.isTrue ||
                  product.quantity! <= 1 ||
                  productController.currentProduct.value?.ownerId?.id == null
              ? Container()
              : AddToCartFAB(
                  product: product,
                ))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FadedScaleAnimation(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Obx(
            () => productController.loadingSingleProduct.isTrue
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.withOpacity(0.3),
                    highlightColor: Colors.grey.withOpacity(0.1),
                    enabled: true,
                    child: _productItem(
                        productController.currentProduct.value == null
                            ? product
                            : productController.currentProduct.value!),
                  )
                : _productItem(productController.currentProduct.value == null
                    ? product
                    : productController.currentProduct.value!),
          ),
        ),
      ),
    );
  }

  _productItem(Product product) => Column(
        children: [
          ProductImages(
            product: product,
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          ProductDescription(product: product),
          if (productController.relatedProducts.isNotEmpty)
            SizedBox(height: getProportionateScreenHeight(20)),
          if (productController.relatedProducts.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: const ExpandableText(
                title: you_might_also_like,
                content: "",
              ),
            ),
          if (productController.relatedProducts.isNotEmpty)
            Obx(
              () => SizedBox(
                height: 200,
                child: ListView(
                  controller: productController.marketplacecontroller,
                  scrollDirection: Axis.horizontal,
                  children: productController.relatedProducts
                      .map((element) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: SingleproductItem(
                              element: element,
                              imageHeight: 90,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ProductReviewsCard(product: product),
          SizedBox(height: getProportionateScreenHeight(100)),
        ],
      );
}
