import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/models/payout_method.dart';
import 'package:tokshop/models/shippingMethods.dart';
import 'package:tokshop/screens/checkout/thank_you.dart';
import 'package:tokshop/services/end_points.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:tokshop/services/notifications_api.dart';
import 'package:tokshop/services/user_api.dart';

import '../models/checkout.dart';
import '../models/product.dart';
import '../services/client.dart';
import '../services/orders_api.dart';
import '../utils/text.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';

class CheckOutController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rxn<Product> product = Rxn();
  Rxn<Checkout> order = Rxn();
  RxInt qty = 0.obs;
  RxInt selectetedvariation = 0.obs;
  RxString selectetedvariationvalue = "".obs;
  RxDouble ordertotal = 0.0.obs;
  RxInt shipping = 0.obs;
  Rxn<ShippingMethods> shippingMethd = Rxn(null);
  RxString checkoutMethod = "".obs;
  var msg = "".obs;
  RxInt tax = 0.obs;
  var tabIndex = 0.obs;
  final formKey = GlobalKey<FormState>();
  Rxn<TabController> tabController = Rxn(null);
  Rxn<PayoutMethod> ownerPayoutMethod = Rxn(PayoutMethod());

  final TextEditingController addressReceiverFieldController =
      TextEditingController();

  final TextEditingController addressLine1FieldController =
      TextEditingController();

  final TextEditingController addressLine2FieldController =
      TextEditingController();

  TextEditingController cityFieldController = TextEditingController();
  TextEditingController countryFieldController = TextEditingController();

  TextEditingController stateFieldController = TextEditingController();

  final TextEditingController phoneFieldController = TextEditingController();

  clearAddressTextControllers() {
    addressReceiverFieldController.clear();
    addressLine1FieldController.clear();
    addressLine2FieldController.clear();
    cityFieldController.clear();
    stateFieldController.clear();
    phoneFieldController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 4,
      vsync: this,
    );
  }

  Future<PayoutMethod?> getPayoutMethodByUserId(String userid) async {
    try {
      var response = await UserAPI().getPayoutMethodByUserId(userid);
      ownerPayoutMethod.value = PayoutMethod.toJson(response[0]);
    } catch (error) {
      return null;
    }
  }

  openStripe(String amount, context) async {
    Get.defaultDialog(
        title: just_a_moment,
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);

    var paymentIntent = await DbBase().databaseRequest(
        createIntentStripeUrl, DbBase().postRequestType,
        body: {
          "amount": amount,
          "productOwner": product.value!.ownerId!.id,
        });

    Get.back();
    try {
      stripe.Stripe.publishableKey = stripePublishKey;
      stripe.Stripe.setReturnUrlSchemeOnAndroid = true;
      await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonDecode(paymentIntent)["client_secret"],
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'US',
        ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'US',
          testEnv: true,
        ),
        style: ThemeMode.light,
        merchantDisplayName: 'Pay',
      ));
      await stripe.Stripe.instance.presentPaymentSheet();
      if (jsonDecode(paymentIntent)["client_secret"] == null) {
        await showConfirmationDialog(
            context, contact_the_shop_owner_about_this_issue,
            positiveResponse: okay, negativeResponse: not_now);
      } else {
        await checkStripeStatus(jsonDecode(paymentIntent)["client_secret"]);
      }
    } catch (e, s) {
      if (jsonDecode(paymentIntent)["error"] != null) {
        await showConfirmationDialog(
            context, contact_the_shop_owner_about_this_issue,
            positiveResponse: okay, negativeResponse: not_now);
      }
      printOut("$e, $s");
    }
  }

  Future<void> checkStripeStatus(String clientSecret,
      {Function? completeOrder}) async {
    await stripe.Stripe.instance
        .retrievePaymentIntent(clientSecret)
        .then((value) async {
      if (value.status.name == "Succeeded") {
        try {
          if (completeOrder != null) {
            completeOrder();
          } else {
            await saveOrder("processing");
          }

          return true;
        } catch (e, s) {
          printOut("Error stripe $e, $s");
        }
      } else if (value.status.name == "requires_payment_method") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "requires_confirmation") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "requires_action") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "processing") {
        await checkStripeStatus(clientSecret);
      }
    });
  }

  Future<void> auctionOrder(Auction auction, Bid bid) async {
    TokShowController tokShowController = Get.find<TokShowController>();
    final AuthController authController = Get.find<AuthController>();

    var serviceFee =
        ((double.parse(auction.higestbid.toString()) * applicationFee * 100))
            .toStringAsFixed(0);

    var order = {
      "shippingId": authController.usermodel.value!.address!.id!,
      "paymentMethod":
          authController.usermodel.value!.defaultpaymentmethod!.name!,
      "productId": auction.product.id!,
      "shopId": auction.product.ownerId!.shopId!.id.toString(),
      "ordertype": "auction",
      "status": "processing",
      'total': (bid.amount - double.parse(serviceFee)).toString(),
      tax: "0",
      "shippingFee": tokShowController
          .currentRoom.value.shopId!.shippingMethods![0].amount,
      "shippingMethd": jsonEncode(tokShowController
          .currentRoom.value.shopId!.shippingMethods![0]
          .toJson()),
      "quantity": 1,
      "productOwnerId": auction.product.ownerId!.id.toString(),
      "variation": ""
    };
    final response = await OrderApi.checkOut(order, auction.product.id!);

    if (response["success"] == true &&
        Get.find<CheckOutController>().msg.value.isEmpty) {
      await NotificationsAPI().sendNotification(
          [auction.product.ownerId!.id],
          "You have a new Order from the auction",
          "You have a new order from ${authController.usermodel.value!.firstName} on your live auction",
          "OrderScreen",
          response["newOrder"]["_id"]);

      await NotificationsAPI().sendNotification(
          [authController.currentuser!.id],
          "Order Won!",
          "Your have  successfully won the auction of ${auction.product.name}",
          "OrderScreen",
          response["newOrder"]["_id"]);
    } else {
      Get.defaultDialog(
          title: response["message"],
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: true);
    }
  }

  Future<void> saveOrder(status) async {
    Get.defaultDialog(
        title: placing_order,
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);

    final AuthController authController = Get.find<AuthController>();
    final UserController userController = Get.find<UserController>();

    var order = {
      "shippingId": userController.myAddresses[0].id!,
      "paymentMethod": checkoutMethod.value,
      "productId": product.value!.id!,
      "status": status,
      "shopId": product.value!.shopId!.id.toString(),
      "total": ordertotal.value.toString(),
      "tax": tax.value.toString(),
      "shippingFee": shipping.value.toString(),
      "shippingMethd": jsonEncode(shippingMethd.value!.toJson()),
      "quantity": int.parse(qty.value.toString()),
      "productOwnerId": product.value!.ownerId!.id.toString(),
      "variation": selectetedvariationvalue.value
    };
    final orderFuture = OrderApi.checkOut(order, product.value!.id!);

    orderFuture.then((response) async {
      if (response["success"] == true &&
          Get.find<CheckOutController>().msg.value.isEmpty) {
        Get.back();
        shipping.value = 0;
        checkoutMethod.value = "";
        tabIndex.value = 0;
        shippingMethd.value = null;
        ordertotal.value = 0;
        try {
          NotificationsAPI().sendNotification(
              [product.value!.ownerId!.id],
              "You have a new Order",
              "You have a new order from ${authController.usermodel.value!.firstName}",
              "OrderScreen",
              response["newOrder"]["_id"]);

          NotificationsAPI().sendNotification(
              [authController.currentuser!.id],
              "Order Successful",
              "Your have  successfully ordered ${product.value!.name}",
              "OrderScreen",
              response["newOrder"]["_id"]);
        } finally {
          const GetSnackBar(
            message: order_successful,
            duration: Duration(seconds: 2),
          ).show();
          Get.back();

          Get.to(() => ThankYouPage(
                order: Order(id: response["newOrder"]["_id"]),
              ));
        }
      } else {
        Get.defaultDialog(
            title: response["message"],
            contentPadding: const EdgeInsets.all(10),
            content: const CircularProgressIndicator(),
            barrierDismissible: true);
      }
    }).catchError((e, s) {
      Get.back();
      print("error one $e");
      GetSnackBar(
              message: Get.find<CheckOutController>().msg.value,
              backgroundColor: Styles.red,
              duration: const Duration(seconds: 2))
          .show();
    });
  }
}
