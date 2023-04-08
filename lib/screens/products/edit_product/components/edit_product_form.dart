import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/services/firestore_files_access_service.dart';
import 'package:tokshop/services/local_files_access_service.dart';
import 'package:tokshop/services/product_api.dart';

import '../../../../utils/text.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/widgets.dart';

//ignore: must_be_immutable
class EditProductForm extends StatelessWidget {
  Product? product;
  EditProductForm({
    Key? key,
    this.product,
  }) : super(key: key);

  final _basicDetailsFormKey = GlobalKey<FormState>();
  final _describeProductFormKey = GlobalKey<FormState>();
  ProductController productController = Get.find<ProductController>();

  bool newProduct = true;
  String btnTxt = add_product;

  Future<bool> uploadProductImages(
      String productId, BuildContext context) async {
    bool allImagesUpdated = true;
    for (int i = 0; i < productController.selectedImages.length; i++) {
      if (productController.selectedImages[i].imgType == ImageType.local) {
        String? downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
              File(productController.selectedImages[i].path),
              ProductPI.getPathForProductImage(productId, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return AsyncProgressDialog(
                imgUploadFuture,
                message: Text(
                    "$uploading_images ${i + 1}/${productController.selectedImages.length}"),
              );
            },
          );
        } finally {
          if (downloadUrl != null) {
            productController.selectedImages[i] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "$couldnt_upload_image ${i + 1} $due_to_some_issue",
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: kPrimaryColor,
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  @override
  Widget build(BuildContext context) {
    if (product != null) {
      btnTxt = update;
      productController.titleFieldController.text =
          productController.product.name!;

      productController.variantFieldController.text =
          productController.product.variations!.join(",");

      productController.originalPriceFieldController.text =
          productController.product.price.toString();

      productController.qtyFieldController.text =
          productController.product.quantity.toString();

      productController.desciptionFieldController.text =
          productController.product.description!;
      productController.pickedProductCategories.value =
          productController.product.interest!;
      productController.discoountedPrice.text =
          productController.product.discountedPrice != null ||
                  productController.product.discountedPrice! <= 0
              ? productController.product.discountedPrice.toString()
              : "";
    } else {
      productController.titleFieldController.text = "";

      productController.variantFieldController.text = "";

      productController.originalPriceFieldController.text = "";

      productController.qtyFieldController.text = "";

      productController.desciptionFieldController.text = "";
    }
    final column = Column(
      children: [
        buildBasicDetailsTile(context),
        buildDescribeProductTile(context),
        SizedBox(height: 10.h),
        buildUploadImagesTile(context),
        Obx(() {
          if (productController.selectedImages.isNotEmpty) {
            return SizedBox(height: 80.h);
          } else {
            return SizedBox(height: 20.h);
          }
        }),
        DefaultButton(
            text: btnTxt,
            txtcolor: Colors.white,
            color: kPrimaryColor,
            press: () async {
              await _saveProduct(context);
            }),
        SizedBox(height: 10.h),
      ],
    );
    return column;
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (_basicDetailsFormKey.currentState!.validate()) {
      String snackbarMessage = "";
      dynamic response;
      if (product != null) {
        response =
            productController.updateProduct(productController.product.id!);
      } else {
        if (productController.selectedImages.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                add_atleast_one_image,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        } else {
          if (productController.pickedProductCategories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  add_at_least_one_category,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          response = productController.saveProduct();
        }
      }
      await showDialog(
        context: context,
        builder: (context) {
          return AsyncProgressDialog(
            response,
            message: Text(productController.productObservable.value != null
                ? updating_product
                : creating_product),
            onError: (e) {
              snackbarMessage = e.toString();
            },
          );
        },
      );
      snackbarMessage = productController.error.value;

      var waitedResponse = await response;
      Product productresponse = Product.fromJson(waitedResponse["data"]);
      productresponse.ownerId = Get.find<AuthController>().usermodel.value;
      productresponse.shopId =
          Get.find<AuthController>().usermodel.value!.shopId;

      await uploadProductImages(productresponse.id!, Get.context!);

      List<dynamic> downloadUrls = productController.selectedImages
          .map((e) => e.imgType == ImageType.network ? e.path : null)
          .toList();

      bool productFinalizeUpdate = false;
      try {
        final updateProductFuture =
            ProductPI.updateProductsImages(productresponse.id!, downloadUrls);
        var productUpdate = await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              updateProductFuture,
              message: Text(productController.productObservable.value != null
                  ? updating_product
                  : creating_product),
            );
          },
        );

        productFinalizeUpdate = productUpdate["success"];
        print("productFinalizeUpdate $productFinalizeUpdate");
        if (productFinalizeUpdate == true) {
          Product savedProduct = Product.fromJson(productUpdate["data"]);
          savedProduct.ownerId = Get.find<AuthController>().usermodel.value;
          savedProduct.shopId =
              Get.find<AuthController>().usermodel.value!.shopId;

          if (product != null) {
            snackbarMessage = product_updated_successfully;

            var index = productController.products
                .indexWhere((element) => element.id == product!.id);
            productController.products[index] = savedProduct;
          } else {
            snackbarMessage = product_uploaded_successfully;
            productController.products.add(savedProduct);
            productController.profileproducts.add(savedProduct);
          }
          productController.products.refresh();
          productController.selectedImages.value = [];
          productController.selectedImages.refresh();
        } else {
          throw "Couldn't upload product properly, please retry";
        }
      } on FirebaseException catch (e) {
        snackbarMessage = "$something_went_wrong$e";
      } catch (e) {
        snackbarMessage = e.toString();
      } finally {
        productController.pickedProductCategories.value = [];
        productController.selectedImages.value = [];
        productController.selectedImages.refresh();
        productController.discoountedPrice.text = "";
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              snackbarMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kPrimaryColor,
          ),
        );
        Get.back();
        // Get.back();
      }
    }
  }

  Widget buildBasicDetailsTile(BuildContext context) {
    return Form(
      key: _basicDetailsFormKey,
      child: ExpansionTile(
        iconColor: primarycolor,
        collapsedIconColor: primarycolor,
        initiallyExpanded: true,
        maintainState: true,
        title: const Text(
          basic_details,
          style: TextStyle(
              color: primarycolor, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: const Icon(
          Icons.shop,
          color: primarycolor,
        ),
        childrenPadding: EdgeInsets.symmetric(vertical: 20.h),
        children: [
          buildTitleField(),
          SizedBox(height: 20.h),
          buildVariantField(),
          SizedBox(height: 20.h),
          buildOriginalPriceField(),
          SizedBox(height: 20.h),
          buildDiscountPriceField(),
          SizedBox(height: 20.h),
          buildQtyField(),
          SizedBox(height: 20.h),
          productController.categories.isEmpty
              ? Text(no_categories_set_by_the_admin,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500))
              : buildInterestField(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget buildDescribeProductTile(BuildContext context) {
    return Form(
      key: _describeProductFormKey,
      child: ExpansionTile(
        iconColor: primarycolor,
        collapsedIconColor: primarycolor,
        maintainState: true,
        initiallyExpanded: true,
        title: const Text(
          describe_product,
          style: TextStyle(
              color: primarycolor, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: const Icon(Icons.description, color: primarycolor),
        childrenPadding: EdgeInsets.symmetric(vertical: 20.h),
        children: [
          buildDescriptionField(),
        ],
      ),
    );
  }

  Future<void> addImageButtonCallback(BuildContext context,
      {int? index}) async {
    String path = "";
    path = await choseImageFromLocalFiles(context);
    if (index == null) {
      productController.selectedImages
          .add(CustomImage(imgType: ImageType.local, path: path));
    } else {
      if (index < productController.selectedImages.length) {
        productController.selectedImages[index] =
            CustomImage(imgType: ImageType.local, path: path);
      }
    }
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      maintainState: true,
      iconColor: primarycolor,
      initiallyExpanded: true,
      collapsedIconColor: primarycolor,
      title: const Text(
        upload_images,
        style: TextStyle(
            color: primarycolor, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      leading: const Icon(Icons.image, color: primarycolor),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconButton(
              icon: const Icon(Icons.add_a_photo, color: primarycolor),
              color: kTextColor,
              onPressed: () {
                addImageButtonCallback(context);
              }),
        ),
        Obx(() => SizedBox(
              height: productController.selectedImages.isEmpty ? 0 : 90.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productController.selectedImages.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 90.h,
                    height: 90.h,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(context, index: index);
                        },
                        child: productController
                                    .selectedImages[index].imgType ==
                                ImageType.local
                            ? Image.memory(File(productController
                                    .selectedImages[index].path)
                                .readAsBytesSync())
                            : Image.network(
                                productController.selectedImages[index].path),
                      ),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }

  Widget buildTitleField() {
    return TextFormField(
      cursorColor: primarycolor,
      style: const TextStyle(color: primarycolor),
      controller: productController.titleFieldController,
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        filled: true,
        hintText: product_name,
        hintStyle: TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (productController.titleFieldController.text.isEmpty) {
          return product_name_is_required;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildVariantField() {
    return TextFormField(
      cursorColor: primarycolor,
      style: const TextStyle(color: primarycolor),
      controller: productController.variantFieldController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        filled: true,
        hintText: product_variant,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(6.0)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (productController.variantFieldController.text.isEmpty) {
          return variations_is_required;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      cursorColor: primarycolor,
      style: const TextStyle(
        color: primarycolor,
      ),
      controller: productController.desciptionFieldController,
      keyboardType: TextInputType.multiline,
      minLines: 8,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20.0),
        filled: true,
        hintStyle: const TextStyle(color: Colors.grey),
        hintText: organic_without_any_effect,
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(6.0)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (productController.desciptionFieldController.text.isEmpty) {
          return decription_is_required;
        }
        return null;
      },
      maxLines: null,
    );
  }

  Widget buildOriginalPriceField() {
    return TextFormField(
      controller: productController.originalPriceFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        hintText: "$price (in $currencySymbol)",
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(6.0)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (productController.originalPriceFieldController.text.isEmpty) {
          return price_is_required;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildQtyField() {
    return TextFormField(
      controller: productController.qtyFieldController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        hintText: quantity_eg,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(6.0)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: (_) {
        if (productController.qtyFieldController.text.isEmpty) {
          return quantity_is_required;
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildDiscountPriceField() {
    return TextFormField(
      controller: productController.discoountedPrice,
      keyboardType: TextInputType.number,
      style:
          const TextStyle(color: primarycolor, fontWeight: FontWeight.normal),
      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        hintText: discounted_price,
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(6.0)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
