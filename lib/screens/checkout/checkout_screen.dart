import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/address.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/menu/address_details_form.dart';
import 'package:tokshop/screens/menu/components/address_short_details_card.dart';
import 'package:tokshop/screens/products/product_details.dart';
import 'package:tokshop/services/user_api.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../shops/components/product_short_detail_card.dart';

//ignore: must_be_immutable
class CheckOut extends StatelessWidget {
  CheckOutController checkOutController = Get.find<CheckOutController>();
  final AuthController authController = Get.find<AuthController>();
  final ShopController shopController = Get.find<ShopController>();
  CheckOut({Key? key}) : super(key: key);

  _disableButton(int index) {
    if (index == 1) {
      if (checkOutController.shippingMethd.value == null) return true;
    }
    if (index == 3) {
      if (checkOutController.checkoutMethod.isEmpty) return true;
    }
  }

  double productPrice = 0.0;
  @override
  Widget build(BuildContext context) {
    if (checkOutController.product.value!.discountedPrice! > 0) {
      productPrice = checkOutController.product.value!.discountedPrice!;
    } else {
      productPrice = checkOutController.product.value!.price!;
    }
    if (checkOutController.product.value != null) {
      checkOutController.getPayoutMethodByUserId(
          checkOutController.product.value!.ownerId!.id!);
    }

    print(checkOutController.product.value!.shopId!.shippingMethods!);
    Get.find<UserController>().gettingMyAddrresses();
    return WillPopScope(
      onWillPop: () async {
        checkOutController.qty.value = 0;
        checkOutController.selectetedvariationvalue.value = "";
        checkOutController.product.value = null;
        return true;
      },
      child: Scaffold(
        bottomNavigationBar: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (checkOutController.tabIndex.value > 0)
                InkWell(
                  onTap: () {
                    if (checkOutController.tabIndex.value > 0) {
                      checkOutController.tabIndex.value--;
                      checkOutController.tabController.value!
                          .animateTo(checkOutController.tabIndex.value);
                    }
                    checkOutController.tabIndex.refresh();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 50),
                    margin: const EdgeInsets.only(bottom: 25),
                    child: const Text(
                      "<< $back",
                      style: TextStyle(color: kPrimaryColor, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              InkWell(
                onTap: _disableButton(checkOutController.tabIndex.value) == true
                    ? null
                    : () async {
                        _calculateTotal(productPrice);
                        if (userController.myAddresses.isEmpty) {
                          checkOutController.tabController.value!.animateTo(0);
                          checkOutController.tabIndex.value = 0;
                          if (checkOutController.formKey.currentState != null &&
                              checkOutController.formKey.currentState!
                                  .validate()) {
                            Address newAddress = Address(
                                id: "",
                                name: checkOutController
                                    .addressReceiverFieldController.text,
                                addrress1: checkOutController
                                    .addressLine1FieldController.text,
                                addrress2: checkOutController
                                    .addressLine2FieldController.text,
                                city:
                                    checkOutController.cityFieldController.text,
                                country: checkOutController
                                    .countryFieldController.text,
                                state: checkOutController
                                    .stateFieldController.text,
                                phone: checkOutController
                                    .phoneFieldController.text,
                                userId: FirebaseAuth.instance.currentUser!.uid);

                            UserAPI.addAddressForCurrentUser(newAddress)
                                .then((value) {
                              Address address = Address.fromJson(value["data"]);
                              userController.myAddresses.add(address);
                            });

                            checkOutController.tabController.value!
                                .animateTo(1);
                            checkOutController.tabIndex.value++;
                          }
                        } else {
                          if (checkOutController.tabIndex.value > 2) {
                            if (checkOutController.checkoutMethod.value ==
                                "cc") {
                              checkOutController.openStripe(
                                  (checkOutController.ordertotal.value +
                                          checkOutController.tax.value +
                                          checkOutController.shipping.value)
                                      .toString(),
                                  Get.context);
                            }
                            if (checkOutController.checkoutMethod.value ==
                                "cod") {
                              await checkOutController.saveOrder("processing");
                            }
                          } else {
                            checkOutController.tabIndex.value++;
                            checkOutController.tabIndex.refresh();
                            checkOutController.tabController.value!
                                .animateTo(checkOutController.tabIndex.value);
                          }
                        }
                      },
                child: Container(
                  width: checkOutController.tabIndex.value == 0
                      ? MediaQuery.of(context).size.width * 0.9
                      : null,
                  decoration: BoxDecoration(
                      color:
                          _disableButton(checkOutController.tabIndex.value) ==
                                  true
                              ? Colors.grey.withOpacity(0.4)
                              : kPrimaryColor,
                      border: Border.all(
                          color: _disableButton(
                                      checkOutController.tabIndex.value) ==
                                  true
                              ? Colors.grey.withOpacity(0.4)
                              : kPrimaryColor),
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  margin: const EdgeInsets.only(bottom: 25),
                  child: Text(
                    checkOutController.tabIndex.value > 2
                        ? place_order
                        : checkOutController.tabIndex.value == 1
                            ? go_to_preview
                            : "$continue_to ${checkOutController.tabIndex.value == 0 ? shipping : checkout}",
                    style: TextStyle(
                        color:
                            _disableButton(checkOutController.tabIndex.value) ==
                                    true
                                ? Colors.black
                                : Colors.white,
                        fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
        body: FadedScaleAnimation(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60, left: 10),
                child: Row(
                  children: [
                    InkWell(
                      child: const Icon(
                        Icons.clear,
                        size: 25,
                      ),
                      onTap: () {
                        Get.back();
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      checkout,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TabBar(
                onTap: (int index) {
                  checkOutController.tabIndex.value = index;
                },
                controller: checkOutController.tabController.value,
                indicatorPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                indicatorWeight: 2,
                isScrollable: true,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.grey),
                indicatorColor: kPrimaryColor,
                tabs: [
                  Tab(
                      child: Text(address,
                          style: TextStyle(
                            color: primarycolor,
                            fontSize: 13.sp,
                          ))),
                  Tab(
                    child: Text(shipping,
                        style: TextStyle(
                          color: primarycolor,
                          fontSize: 13.sp,
                        )),
                  ),
                  Tab(
                    child: Text(preview,
                        style: TextStyle(
                          color: primarycolor,
                          fontSize: 13.sp,
                        )),
                  ),
                  Tab(
                    child: Text(payment,
                        style: TextStyle(
                          color: primarycolor,
                          fontSize: 13.sp,
                        )),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Obx(
                    () => TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: checkOutController.tabController.value,
                      children: [
                        userController.myAddresses.isNotEmpty
                            ? Column(
                                children: [
                                  AddressShortDetailsCard(
                                    address: userController.myAddresses[0],
                                    onTap: () async {
                                      // await addressItemTapCallback(address, context);
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => AddressDetailsForm(
                                            showsave: true,
                                          ));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Text(
                                        userController.myAddresses.isNotEmpty
                                            ? new_address
                                            : "",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : InkWell(
                                onTap: () {
                                  Get.to(() => AddressDetailsForm(
                                        showsave: true,
                                      ));
                                },
                                child: Center(
                                  child: Text(
                                    shipping_address,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: kPrimaryColor, fontSize: 13.sp),
                                  ),
                                ),
                              ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipping_method,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(
                              () => Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: checkOutController
                                    .product.value!.shopId!.shippingMethods!
                                    .map((e) => InkWell(
                                          onTap: () {
                                            checkOutController.shipping.value =
                                                int.parse(e.amount.toString());
                                            checkOutController
                                                .shippingMethd.value = e;
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Radio<dynamic>(
                                                  activeColor: kPrimaryColor,
                                                  value: e.name,
                                                  groupValue: checkOutController
                                                              .shippingMethd
                                                              .value ==
                                                          null
                                                      ? 0
                                                      : checkOutController
                                                          .shippingMethd
                                                          .value!
                                                          .name,
                                                  onChanged: (value) {},
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.name,
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                    Text(
                                                        "$currencySymbol ${e.amount}"),
                                                    const Divider(
                                                      height: 5,
                                                      color: Colors.red,
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            buildCartItemsList(context),
                            SizedBox(height: 10.h),
                            _orderSummary()
                          ],
                        ),
                        if (checkOutController.ownerPayoutMethod.value == null)
                          Center(
                            child: Text(
                              setup_payment_method_notset,
                              style: TextStyle(fontSize: 15.sp),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (checkOutController.ownerPayoutMethod.value != null)
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: primarycolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 15),
                              child: Column(
                                children: [
                                  Column(
                                    children: checkOutController
                                        .product.value!.shopId!.paymentOptions!
                                        .map((e) => Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Column(
                                                children: [
                                                  InkWell(
                                                    child: Row(
                                                      children: [
                                                        Radio<dynamic>(
                                                          activeColor:
                                                              kPrimaryColor,
                                                          value: e,
                                                          groupValue: checkOutController
                                                                  .checkoutMethod
                                                                  .value
                                                                  .isEmpty
                                                              ? 0
                                                              : checkOutController
                                                                  .checkoutMethod
                                                                  .value,
                                                          onChanged: (value) {},
                                                        ),
                                                        Row(
                                                          children: [
                                                            e == "cod"
                                                                ? const Icon(
                                                                    Icons.group,
                                                                  )
                                                                : e == "cc"
                                                                    ? const Icon(
                                                                        Icons
                                                                            .credit_card_outlined,
                                                                      )
                                                                    : Text(""),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              e == "cc"
                                                                  ? credit_card
                                                                  : e == "cod"
                                                                      ? cash_on_delivery
                                                                      : e == "fw"
                                                                          ? flutter_wave
                                                                          : e,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14.sp,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    onTap: () {
                                                      checkOutController
                                                          .checkoutMethod
                                                          .value = e;
                                                    },
                                                  ),
                                                  const Divider()
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                  _orderSummary()
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _orderSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                subtotal,
                style: TextStyle(fontSize: 16),
              ),
              Text(
                checkOutController.product.value!.htmlPrice(
                    checkOutController.product.value!.discountedPrice! > 0
                        ? checkOutController.product.value!.discountedPrice! *
                            checkOutController.qty.value
                        : checkOutController.product.value!.price! *
                            checkOutController.qty.value),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (checkOutController.shippingMethd.value != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  checkOutController.shippingMethd.value!.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  checkOutController.product.value!
                      .htmlPrice(checkOutController.shipping.value),
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
                )
              ],
            ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                total,
                style: TextStyle(fontSize: 21),
              ),
              Text(
                checkOutController.product.value!.htmlPrice(
                    (checkOutController.product.value!.discountedPrice! > 0
                            ? checkOutController
                                    .product.value!.discountedPrice! *
                                checkOutController.qty.value
                            : checkOutController.product.value!.price! *
                                checkOutController.qty.value) +
                        checkOutController.shipping.value),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 21.sp,
                    decoration: TextDecoration.underline),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> refreshPage() {
    return Future<void>.value();
  }

  Widget buildCartItemsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order_details,
          style: TextStyle(fontSize: 14.sp),
        ),
        Container(
          padding: const EdgeInsets.only(
            bottom: 4,
            top: 4,
            right: 4,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ProductShortDetailCard(
            product: checkOutController.product.value,
            onPressed: () {
              Get.to(() => ProductDetails(
                    product: checkOutController.product.value!,
                  ));
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          width: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                  ),
                ),
                onTap: () async {
                  if (checkOutController.qty.value - 1 > 0) {
                    checkOutController.qty.value -= 1;
                    _calculateTotal(productPrice);
                  } else {
                    showSnackBack(context, zero_products, color: Colors.red);
                  }
                  // await arrowDownCallback(cartItemId);
                },
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    checkOutController.qty.value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  )),
              const SizedBox(height: 8),
              InkWell(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                ),
                onTap: () async {
                  if (checkOutController.qty.value + 1 <=
                      checkOutController.product.value!.quantity!) {
                    checkOutController.qty.value += 1;
                    _calculateTotal(productPrice);
                  } else {
                    showSnackBack(context, not_enough_stock, color: Colors.red);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _calculateTotal(double productPrice) {
    checkOutController.ordertotal.value =
        checkOutController.qty.value.toDouble() * productPrice;
    checkOutController.ordertotal.refresh();
  }
}
