import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/wallet_controller.dart';
import 'package:tokshop/services/local_files_access_service.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../services/user_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ApplyToSell extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ShopController shopController = Get.find<ShopController>();
  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();

  final _formKey = GlobalKey<FormState>();

  ApplyToSell({Key? key}) : super(key: key);

  void showSnackBar(String string, String color) {
    SnackBar(
      content: Text(
        string,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
        ),
      ),
      backgroundColor: kPrimaryColor,
      action: SnackBarAction(
        label: ok,
        textColor: Colors.white,
        onPressed: () {},
      ),
      elevation: 4.0,
    );
  }

  Widget buildDisplayPictureAvatar(BuildContext context) {
    ImageProvider? backImage;
    if (shopController.chosenImage.path != "") {
      backImage = MemoryImage(shopController.chosenImage.readAsBytesSync());
    } else if (authController.currentuser!.shopId?.id != null &&
        authController.currentuser!.shopId!.image != null &&
        authController.currentuser!.shopId!.image!.isNotEmpty) {
      final String? url = authController.currentuser!.shopId!.image;
      if (url != null) backImage = NetworkImage(url);
    }
    return Container(
      height: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: backImage ?? AssetImage(imageplaceholder),
          fit: BoxFit.cover,
        ),
      ),
      child: null,
    );
  }

  void getImageFromUser(BuildContext context) async {
    String path;
    String snackbarMessage = "";
    try {
      path = await choseImageFromLocalFiles(context,
          aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2));
      snackbarMessage = image_picked;
    } finally {
      if (snackbarMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              snackbarMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kPrimaryColor,
          ),
        );
      }
    }
    shopController.setChosenImage = File(path);
  }

  final WalletController walletController = Get.find<WalletController>();
  @override
  Widget build(BuildContext context) {
    if (authController.currentuser!.shopId != null) {
      shopController
          .getShopById(authController.currentuser!.shopId?.id.toString());

      shopController.nameController.text =
          shopController.currentShop.value.name!;

      shopController.mpesanumberController.text =
          authController.currentuser!.mpesaNumber!;
      productController.pickedProductCategories.value =
          shopController.currentShop.value.interests!;
    } else {
      shopController.nameController.text = "";
      shopController.daddressController.text = "";

      shopController.descriptionController.text = "";
      shopController.mpesanumberController.text = "";
    }
    return shopController.loadingShop.isTrue
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              title: Text(
                  authController.currentuser!.shopId == null
                      ? apply_to_sell
                      : update_brand,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: primarycolor)),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String snackbarMessage = "";
                      dynamic response;
                      if (authController.currentuser?.shopId != null) {
                        response = shopController.updateShop(
                            authController.currentuser!.shopId!.id!);
                      }
                      if (authController.currentuser?.shopId == null) {
                        response = shopController.saveShop();
                      }
                      try {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AsyncProgressDialog(
                              response,
                              message: Text(
                                authController.currentuser!.shopId != null
                                    ? "$updating..."
                                    : creating_a_brand,
                              ),
                              onError: (e) {
                                snackbarMessage = e.toString();
                              },
                            );
                          },
                        );
                        snackbarMessage = shopController.error.value;
                      } catch (e, s) {
                        printOut("Update save shop $e, $s");
                      } finally {
                        if (shopController.error.value.isEmpty) {
                          authController.usermodel.value =
                              await UserAPI.getUserById();
                          authController.usermodel.refresh();
                          Get.back();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                snackbarMessage,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: kPrimaryColor,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 5),
                      child: Text(
                        authController.currentuser!.shopId != null
                            ? "$update".toUpperCase()
                            : "$submit".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: kPrimaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Obx(() {
                return Column(
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ExpansionTile(
                                iconColor: primarycolor,
                                collapsedIconColor: kPrimaryColor,
                                initiallyExpanded: true,
                                maintainState: true,
                                expandedCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                title: const Text(
                                  brand_information,
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                leading: const Icon(
                                  Icons.shop,
                                  color: primarycolor,
                                ),
                                children: [
                                  const Text(
                                    cover_photo,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: primarycolor,
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      child: GestureDetector(
                                        child:
                                            buildDisplayPictureAvatar(context),
                                        onTap: () {
                                          getImageFromUser(context);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: primarycolor,
                                        ),
                                      ),
                                      Text(
                                        if_you_provide_brand_name,
                                        style: TextStyle(
                                          fontSize: 11.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  TextFormField(
                                    style: const TextStyle(color: primarycolor),
                                    controller: shopController.nameController,
                                    toolbarOptions: const ToolbarOptions(
                                      paste: true,
                                      selectAll: false,
                                    ),
                                    validator: (value) {
                                      if (shopController
                                          .nameController.text.isEmpty) {
                                        return name_required;
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      filled: true,
                                      hintText: name_that_identifies_brand,
                                      hintStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(15),
                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      prefixIcon: const Icon(Icons.storefront,
                                          color: Styles.dullGreyColor),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autocorrect: false,
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  buildInterestField()
                                ],
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                            ],
                          ),
                        ))
                  ],
                );
              }),
            ),
          );
  }
}
