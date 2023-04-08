import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/utils/text.dart';
import 'package:tokshop/widgets/product_image.dart';

import '../../../controllers/checkout_controller.dart';
import '../../../models/product.dart';
import '../../../utils/utils.dart';

class ProductShortDetailCard extends StatelessWidget {
  final Product? product;
  final VoidCallback? onPressed;
  ProductShortDetailCard({
    Key? key,
    @required this.product,
    @required this.onPressed,
  }) : super(key: key);

  final CheckOutController checkOutController = Get.find<CheckOutController>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressed,
      child: Row(
        children: [
          SizedBox(
            width: 88.w,
            child: AspectRatio(
              aspectRatio: 0.88,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ProductImage(
                  element:
                      product!.images!.isNotEmpty ? product!.images![0] : "",
                  size: 30,
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Obx(() {
            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!.name!,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  if (checkOutController.selectetedvariationvalue.isEmpty)
                    Text(
                      "$variations: ${checkOutController.selectetedvariationvalue}",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15.sp),
                    ),
                  product!.discountedPrice! > 0
                      ? Text.rich(
                          TextSpan(
                              text:
                                  "${product!.htmlPrice(product!.discountedPrice!)}    ",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: "${product!.htmlPrice(product!.price)}",
                                  style: TextStyle(
                                    color: Styles.dullGreyColor,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ]),
                        )
                      : Text(
                          "${product!.htmlPrice(product!.price! * checkOutController.qty.value)}",
                          style: TextStyle(fontSize: 15.sp),
                        ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
