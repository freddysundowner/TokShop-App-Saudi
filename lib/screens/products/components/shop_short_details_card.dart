import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/products/edit_product/edit_product_screen.dart';

import '../../../controllers/product_controller.dart';
import '../../../models/product.dart';
import '../../../services/product_api.dart';
import '../../../utils/text.dart';
import '../../../utils/utils.dart';

class ShopShortDetailCard extends StatelessWidget {
  final Product? product;
  final String? actionfrom;
  final VoidCallback? onPressed;
  final Function? callBack;
  final ProductController productController = Get.find<ProductController>();
  ShopShortDetailCard({
    Key? key,
    @required this.product,
    this.actionfrom,
    @required this.onPressed,
    this.callBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Styles.greenTheme.withOpacity(0.25)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.88,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: product!.images!.isNotEmpty
                          ? CachedNetworkImage(
                              errorWidget: (context, v, dynamic) => Image.asset(
                                imageplaceholder,
                                fit: BoxFit.fitHeight,
                              ),
                              imageBuilder: (context, provider) => Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      image: DecorationImage(
                                          image:
                                              NetworkImage(product!.images![0]),
                                          fit: BoxFit.fitHeight))),
                              imageUrl: product!.images![0],
                              fit: BoxFit.fitHeight,
                            )
                          : Image.asset(
                              imageplaceholder,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 0.02.sw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.name!,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (product!.description!.isNotEmpty)
                        Text(
                          product!.description!.length > 30
                              ? "${product!.description!.substring(0, 30)}..."
                              : product!.description.toString(),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                          maxLines: 2,
                        ),
                      Text(
                        "$currencySymbol${product!.price}    ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (product?.ownerId?.id ==
                    FirebaseAuth.instance.currentUser!.uid)
                  Row(
                    children: [
                      InkWell(
                        onTap: actionfrom == "favorite"
                            ? () {
                                callBack!("delete");
                              }
                            : () async {
                                final confirmation =
                                    await showConfirmationDialog(context,
                                        are_you_sure_you_want_to_delete_product);
                                if (await confirmation) {
                                  for (int i = 0;
                                      i < product!.images!.length;
                                      i++) {}

                                  bool productInfoDeleted = false;

                                  var deleteProduct =
                                      await ProductPI.updateProduct(
                                          {"deleted": true}, product!.id!);
                                  productInfoDeleted = deleteProduct["success"];
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
                                // await refreshPage();
                              },
                        child: const Icon(
                          Icons.delete_forever_outlined,
                          color: Styles.neutralGrey,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      if (actionfrom == null)
                        InkWell(
                            onTap: () async {
                              final confirmation = await showConfirmationDialog(
                                  context, are_you_sure_to_edit_product);
                              if (confirmation) {
                                productController.product = product!;
                                productController.selectedImages.assignAll(
                                    productController.product.images!
                                        .map((e) => CustomImage(
                                            imgType: ImageType.network,
                                            path: e))
                                        .toList());

                                Get.to(() => EditProductScreen(
                                      product: product,
                                    ));
                              }
                              // await refreshPage();
                            },
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Styles.neutralGrey,
                            )),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    return Future<void>.value();
  }
}
