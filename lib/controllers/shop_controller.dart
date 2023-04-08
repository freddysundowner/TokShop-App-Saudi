import 'dart:convert';
import 'dart:io';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/controllers/wallet_controller.dart';
import 'package:tokshop/models/payout_method.dart';
import 'package:tokshop/services/client.dart';
import 'package:tokshop/services/end_points.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/shop.dart';
import '../models/user.dart';
import '../services/firestore_files_access_service.dart';
import '../services/shop_api.dart';
import '../utils/text.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';

class ShopController extends GetxController with GetTickerProviderStateMixin {
  final Rxn<Brand> _shop = Rxn();
  get shop => _shop.value;
  RxString error = "".obs;
  var searchedShops = [].obs;
  var isSearchingShop = false.obs;
  var loadingShop = false.obs;
  var creatingflutterwaveAccount = false.obs;
  var importLoading = false.obs;
  var gettingBankCodes = false.obs;
  var bankCodes = [].obs;
  var currentShop = Brand().obs;
  var creatingStripeAccount = false.obs;
  var searchEnabled = false.obs;
  var userStripeAccountId = "".obs;

  RxList<Brand> homeBrandList = RxList([]);
  RxList<Brand> allBrandsList = RxList([]);
  var loadingshops = false.obs;
  var accountNumberController = TextEditingController();
  var firstNameController = TextEditingController();
  var businessNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var routingNumberController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var postalCodeController = TextEditingController();
  var ssnNumberController = TextEditingController();
  var bankName = TextEditingController();
  var pickedCountry = 0.obs;

  var bankCodeController = TextEditingController();
  var countryCodeController = TextEditingController();

  var countriesToPick = ["US", "KE"];
  var accountCountry = "".obs;
  var accountState = "".obs;
  var accountCity = "".obs;
  var addressController = TextEditingController();
  var birthDateHolder = "".obs;
  final Rx<File> _chosenImage = Rx(File(""));
  File get chosenImage => _chosenImage.value;
  AuthController authController = Get.put(AuthController());
  Rxn<TabController> tabController = Rxn(null);
  var tabIndex = 0.obs;
  set setChosenImage(File img) {
    _chosenImage.value = img;
  }

  TextEditingController nameController = TextEditingController(),
      mobileController = TextEditingController(),
      descriptionController = TextEditingController(),
      daddressController = TextEditingController(),
      mpesanumberController = TextEditingController(),
      emailController = TextEditingController();
  var isScrroll = true.obs;
  var searchPageNumber = 1.obs;

  @override
  void onInit() {
    super.onInit();
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 2,
      vsync: this,
    );
  }

  shopCustomScroll() {
    final scrollcontroller = ScrollController();
    scrollcontroller.addListener(() {
      if (scrollcontroller.position.atEdge) {
        var nextPageTrigger = 0.7 * scrollcontroller.position.maxScrollExtent;
        if (scrollcontroller.position.pixels > nextPageTrigger) {
          if (isScrroll.isTrue) {
            _getShops(page: searchPageNumber.value.toString());
          }
        }
      }
    });
    return scrollcontroller;
  }

  _getShops({String page = "1", String title = ""}) async {
    var response = await BrandApi.getAllBrands(page, title: title);
    List list = response["shops"];
    allBrandsList.addAll(list.map((e) => Brand.fromJson(e)).toList());
    if (response["totalDoc"] > allBrandsList.length) {
      searchPageNumber.value++;
    } else {
      isScrroll.value = false;
    }
  }

  getBrands({String page = "1", String title = "", String type = ""}) async {
    try {
      searchPageNumber.value = 1;
      isScrroll.value = true;
      isSearchingShop.value = true;
      var response = await BrandApi.getAllBrands(page, title: title);

      List list = response["shops"];
      if (type == "home") {
        homeBrandList.clear();
        homeBrandList.value = list.map((e) => Brand.fromJson(e)).toList();
      } else {
        allBrandsList.clear();
        allBrandsList.value = list.map((e) => Brand.fromJson(e)).toList();
      }
      if (response["totalDoc"] > allBrandsList.length) {
        searchPageNumber.value++;
      }
      isSearchingShop.value = false;
      refresh();
    } catch (e) {
      printOut(e);
      isSearchingShop.value = false;
    }
  }

  saveShop() async {
    try {
      if (stripeSecretKey.isEmpty) {
        error.value = stripe_secret_key_admin;
      } else {
        if (chosenImage.path.isEmpty) {
          error.value = add_cover_photo;
        } else if (Get.find<ProductController>()
            .pickedProductCategories
            .isEmpty) {
          error.value = select_atleast_one_interest;
        } else {
          Map<String, dynamic> productdata = {
            "name": nameController.text.isEmpty
                ? authController.usermodel.value!.firstName
                : nameController.text,
            "interest": Get.find<ProductController>()
                .pickedProductCategories
                .map((element) => element.id)
                .toList(),
            'first_name': authController.usermodel.value!.firstName!,
            'last_name': authController.usermodel.value!.firstName!,
            'email': authController.usermodel.value!.email!,
          };
          var response = await BrandApi.saveShop(productdata);
          error.value = "";
          if (response["success"]) {
            if (chosenImage.path.isNotEmpty) {
              final downloadUrl = await FirestoreFilesAccess().uploadFileToPath(
                  chosenImage,
                  BrandApi.getPathForShop(response["data"]["_id"]));
              await BrandApi.updateShop(
                  {"image": downloadUrl}, response["data"]["_id"]);
              Get.find<UserController>().currentProfile.value.shopId =
                  Brand.fromJson(response["data"]);
              if (response["account"] != null) {
                PayoutMethod? payoutMethod =
                    PayoutMethod.toJson(response["account"]["account"]);
                authController.usermodel.value!.payoutMethod = payoutMethod;
                authController.usermodel.refresh();
              }

              Get.find<UserController>().currentProfile.refresh();
            }
          } else {
            error.value = response["message"];
          }
          return response;
        }
      }
    } catch (e, s) {
      printOut("Error saving product $e $s");
    }
  }

  createStripeConnectAccount() async {
    creatingStripeAccount.value = true;
    var birthDate = DateTime(1900, 5, 5);

    if (birthDateHolder.value.isNotEmpty) {
      birthDate = DateTime.parse(birthDateHolder.value);
    }
    var payload = {
      "country": "US",
      "currency": "usd",
      "account_number": accountNumberController.text,
      "city": accountCity.value,
      "state": accountState.value,
      "day": birthDate.day.toString(),
      "month": birthDate.month.toString(),
      "year": birthDate.year.toString(),
      "ssn_last_4": ssnNumberController.text,
      "address_one": addressController.text,
      "address_two": addressController.text,
      "postal_code": postalCodeController.text,
      "phone": phoneNumberController.text,
      "routing_number": routingNumberController.text,
      "email": authController.usermodel.value!.email!,
      'name': authController.usermodel.value!.firstName!,
      'first_name': authController.usermodel.value!.firstName!,
      'last_name': authController.usermodel.value!.firstName!,
      'account_holder_name':
          "${authController.usermodel.value!.firstName!} ${authController.usermodel.value!.lastName!}",
    };
    var respnse = await DbBase().databaseRequest(
        connectStripeBase + FirebaseAuth.instance.currentUser!.uid,
        DbBase().postRequestType,
        body: payload);
    print("respnse $respnse");
    var payoutmethod = jsonDecode(respnse);

    if (payoutmethod["error"] != null) {
      creatingStripeAccount.value = false;
      Get.snackbar(
        "",
        "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 30),
        messageText: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                payoutmethod["error"],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SnackBarAction(
              label: dismiss,
              textColor: Colors.white,
              onPressed: () {
                Get.back();
              },
            )
          ],
        ),
        colorText: Colors.white,
        margin: const EdgeInsets.all(0),
      );
      return;
    }

    if (payoutmethod["account"]["success"] == true) {
      PayoutMethod? payoutMethod = PayoutMethod.toJson(payoutmethod["account"]);
      authController.usermodel.value!.payoutMethod = payoutMethod;
      authController.usermodel.refresh();
      creatingStripeAccount.value = false;
      Get.back();
      Get.snackbar(
        "",
        successfully_connected_your_bank_account,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        messageText: const Text(
          successfully_connected_your_bank_account,
          style: TextStyle(color: Colors.white),
        ),
        colorText: Colors.white,
        margin: const EdgeInsets.all(0),
      );
    } else {
      Get.snackbar(
        "",
        "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 30),
        messageText: const Text(error_happened),
        colorText: Colors.white,
        margin: const EdgeInsets.all(0),
      );
    }
  }

  updateShop(String id) async {
    String imageurl = Get.find<AuthController>().currentuser!.shopId!.image!;
    if (chosenImage.path.isNotEmpty) {
      imageurl = await FirestoreFilesAccess().uploadFileToPath(
          chosenImage,
          BrandApi.getPathForShop(
              Get.find<AuthController>().currentuser!.shopId!.id!));
    }
    Map<String, dynamic> productdata = {
      "name": nameController.text,
      "description": descriptionController.text,
      "image": imageurl,
      "location": daddressController.text
    };
    var response = await BrandApi.updateShop(productdata, id);
    error.value = "";
    if (response["success"]) {
      error.value = updated_successfully;
      ShopId.fromJson(response["data"]);

      _shop.value = Brand.fromJson(response["data"]);
      currentShop.value = Brand.fromJson(response["data"]);
      Get.find<AuthController>().currentuser!.shopId =
          Brand.fromJson(response["data"]);

      if (mpesanumberController.text.isNotEmpty &&
          Get.find<WalletController>().paymentMethodPicked.value == "mpesa") {
        var user = await UserAPI().updateUser({
          "mpesaNumber": mpesanumberController.text,
          "payout_method":
              Get.find<WalletController>().paymentMethodPicked.value
        }, Get.find<AuthController>().usermodel.value!.id!);
        Get.find<AuthController>().usermodel.value = UserModel.fromJson(user);
      }
    } else {
      error.value = response["message"];
    }
    return response;
  }

  getShopById(String? shopid) async {
    loadingShop.value = false;
    try {
      var shop = await BrandApi().getShopById(shopid);
      if (shop != null) {
        currentShop.value = Brand.fromJson(shop);
      }
      loadingShop.value = false;
    } catch (e) {
      loadingShop.value = false;
    }
  }

  getBankCodes(String country) async {
    try {
      creatingflutterwaveAccount.value = true;
      bankCodes.clear();

      var codes = await BrandApi.getBanks(country);
      if (codes["data"] == null) {
        showDialog(
          context: Get.context!,
          builder: (context) {
            return AlertDialog(
              title: const Text(errors),
              content: const Text(no_banks_found_in_your_country_to_payout),
              actions: [
                TextButton(
                  child: const Text(okay),
                  onPressed: () async {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          },
        );
      } else {
        bankCodes.assignAll(codes["data"]);
      }
      creatingflutterwaveAccount.value = false;
      // Get.back();
    } catch (e) {
      creatingflutterwaveAccount.value = false;
      // Get.back();
    }
  }

  createFlutterAccount() async {
    try {
      creatingflutterwaveAccount.value = true;
      var data = {
        "bankcode": bankCodeController.text,
        "accountnumber": accountNumberController.text,
        "businessname": businessNameController.text,
        "email": Get.find<AuthController>().usermodel.value!.email,
        "phone": phoneNumberController.text,
        "country": countryCodeController.text,
      };

      var response = await BrandApi.createFlutterrWaveAccount(
          data, FirebaseAuth.instance.currentUser!.uid);
      if (response["status"] == "error") {
        showDialog(
          context: Get.context!,
          builder: (context) {
            return AlertDialog(
              title: const Text(errors),
              content: const Text(error_when_setting_flutterwave),
              actions: [
                TextButton(
                  child: const Text(okay),
                  onPressed: () async {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: Get.context!,
          builder: (context) {
            return AlertDialog(
              title: const Text(success),
              content: const Text(flutterWave_set_up_successful),
              actions: [
                TextButton(
                  child: const Text(proceed),
                  onPressed: () async {
                    Get.back();
                    Get.back();
                    authController.usermodel.value!.shopId!.paymentOptions!
                        .add("fw");

                    await BrandApi.updateShop({
                      "paymentOptions": authController
                          .usermodel.value!.shopId!.paymentOptions!
                    }, authController.currentuser!.shopId!.id!);
                    authController.usermodel.refresh();
                  },
                ),
              ],
            );
          },
        );
      }

      creatingflutterwaveAccount.value = false;
    } catch (e) {
      creatingflutterwaveAccount.value = false;
    }
  }

  importWcProducts({String type = "check"}) async {
    try {
      importLoading.value = true;

      var response = await BrandApi.importWcProducts(type);
      Get.back();
      if (response["status"] == true) {
        Get.defaultDialog(
            title: successful,
            contentPadding: const EdgeInsets.all(10),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: Text(response["message"])),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: const Text(
                    okay,
                    style: TextStyle(color: Styles.greenTheme),
                  ),
                ),
              ],
            ),
            barrierDismissible: true);
      } else {
        if (response["alert"] == true) {
          Get.defaultDialog(
              title: alert,
              contentPadding: const EdgeInsets.all(10),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: Text(response["message"])),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Text(
                          not_now,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                          Get.defaultDialog(
                              title: "$updating_products...",
                              contentPadding: const EdgeInsets.all(10),
                              content: const CircularProgressIndicator(),
                              barrierDismissible: true);
                          importWcProducts(type: "update");
                        },
                        child: const Text(
                          update,
                          style: TextStyle(color: Styles.red),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Get.back();
                          Get.defaultDialog(
                              title: "$trying_to_import...",
                              contentPadding: const EdgeInsets.all(10),
                              content: const CircularProgressIndicator(),
                              barrierDismissible: true);
                          importWcProducts(type: "import");
                        },
                        child: const Text(
                          import_new,
                          style: TextStyle(color: Styles.greenTheme),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              barrierDismissible: true);
        } else {
          Get.defaultDialog(
              title: successful,
              contentPadding: const EdgeInsets.all(10),
              content: Column(
                children: [
                  Text(response["message"]),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Text(
                      okay,
                      style: TextStyle(color: Styles.blueSecondary),
                    ),
                  ),
                ],
              ),
              barrierDismissible: true);
        }
      }
      printOut(response["message"]);
      GetSnackBar(
        title: response["message"],
      );
      printOut(response);
      // Get.back();
      importLoading.value = false;
    } catch (e) {
      printOut(e);
      Get.back();
      importLoading.value = false;
    }
  }

  importSpProducts({String type = "check"}) async {
    try {
      importLoading.value = true;

      var response = await BrandApi.importSpProducts(type);
      Get.back();
      if (response["status"] == true) {
        Get.defaultDialog(
            title: successful,
            contentPadding: const EdgeInsets.all(10),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: Text(response["message"])),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: const Text(
                    okay,
                    style: TextStyle(color: Styles.greenTheme),
                  ),
                ),
              ],
            ),
            barrierDismissible: true);
      } else {
        if (response["alert"] == true) {
          Get.defaultDialog(
              title: alert,
              contentPadding: const EdgeInsets.all(10),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: Text(response["message"])),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Text(
                          not_now,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                          Get.defaultDialog(
                              title: "$updating_products...",
                              contentPadding: const EdgeInsets.all(10),
                              content: const CircularProgressIndicator(),
                              barrierDismissible: true);
                          importSpProducts(type: "update");
                        },
                        child: const Text(
                          update,
                          style: TextStyle(color: Styles.red),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Get.back();
                          Get.defaultDialog(
                              title: "$trying_to_import...",
                              contentPadding: const EdgeInsets.all(10),
                              content: const CircularProgressIndicator(),
                              barrierDismissible: true);
                          importSpProducts(type: "import");
                        },
                        child: const Text(
                          import_new,
                          style: TextStyle(color: Styles.greenTheme),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              barrierDismissible: true);
        } else {
          Get.defaultDialog(
              title: successful,
              contentPadding: const EdgeInsets.all(10),
              content: Column(
                children: [
                  Text(response["message"]),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Text(
                      okay,
                      style: TextStyle(color: Styles.blueSecondary),
                    ),
                  ),
                ],
              ),
              barrierDismissible: true);
        }
      }
      printOut(response["message"]);
      GetSnackBar(
        title: response["message"],
      );
      printOut(response);
      // Get.back();
      importLoading.value = false;
    } catch (e) {
      printOut(e);
      Get.back();
      importLoading.value = false;
    }
  }
}
