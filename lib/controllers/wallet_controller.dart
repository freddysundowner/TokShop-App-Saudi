import 'dart:async';
import 'dart:convert';

import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/models/stripe_account.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/services/end_points.dart';

import '../screens/home/main_page.dart';
import '../services/client.dart';
import '../services/transaction_api.dart';
import '../services/user_api.dart';
import '../utils/text.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';

class WalletController extends GetxController {
  var userTransaction = [].obs;
  var transactionsLoading = false.obs;
  var moreTransactionsLoading = false.obs;
  var transactionPageNumber = 0.obs;
  final transactionScrollController = ScrollController();
  var consumables = <String>[].obs;
  var purchasePending = false.obs;
  var previousPurchaseId = "".obs;
  var transactionFilter = "".obs;
  var filteredTransactionsList = [].obs;
  var creatingStripeAccount = false.obs;
  var gettingStripeAccount = false.obs;
  var userStripeAccountId = "".obs;
  var userStripeAccountData = StripeAccount().obs;
  var paymentMethodPicked = "".obs;
  ShopController shopController = Get.find<ShopController>();
  var withdrawing = false.obs;
  var withdrawAmountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    transactionScrollController.addListener(() {
      if (transactionScrollController.position.atEdge) {
        bool isTop = transactionScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          printOut('At the bottom');
          transactionPageNumber.value = transactionPageNumber.value + 1;
          getMoreTransactions();
        }
      }
    });
  }

  getUserTransactions() async {
    try {
      transactionsLoading.value = true;

      var transactions = await TransactionAPI().getUserTransactions();

      if (transactions != null) {
        userTransaction.value = transactions;
      } else {
        userTransaction.value = [];
      }
      filteredTransactionsList.value = userTransaction;

      transactionsLoading.value = false;
    } catch (e, s) {
      transactionsLoading.value = false;
      printOut("Error getting user transactions $e $s");
    }
  }

  getMoreTransactions() async {
    try {
      moreTransactionsLoading.value = true;

      var transactions = await TransactionAPI()
          .getMoreUserTransactions(transactionPageNumber.value);

      printOut("transactions $transactions");

      if (transactions != null && transactions != []) {
        for (var i = 0; i < transactions.length; i++) {
          userTransaction.add(transactions.elementAt(i));
        }

        filteredTransactionsList.value = userTransaction;
      }
      moreTransactionsLoading.value = false;
    } catch (e, s) {
      transactionsLoading.value = false;
      printOut("Error getting more user transactions $e $s");
    }
  }

  filterTransactions() {
    if (transactionFilter.value != "") {
      filteredTransactionsList.value = [];

      for (var i = 0; i < userTransaction.length; i++) {
        if (userTransaction.elementAt(i)["status"] == transactionFilter.value) {
          filteredTransactionsList.add(userTransaction.elementAt(i));
        }
      }
    } else {
      getUserTransactions();
    }
  }

  Future<void> createStripeAccount() async {
    try {
      creatingStripeAccount.value = true;
      String ip = await Ipify.ipv4();
      var currentIP = ip;

      var birthDate = DateTime(1900, 5, 5);

      if (shopController.birthDateHolder.value.isNotEmpty) {
        birthDate = DateTime.parse(shopController.birthDateHolder.value);
      }

      var data = {
        "type": "custom",
        "email": Get.find<AuthController>().usermodel.value!.email!,
        'capabilities[card_payments][requested]': 'true',
        'capabilities[transfers][requested]': 'true',
        'external_account[object]': 'bank_account',
        'external_account[country]': 'US',
        'external_account[currency]': 'usd',
        'external_account[account_holder_name]':
            "${shopController.firstNameController.text} ${shopController.lastNameController.text}",
        'external_account[account_holder_type]': 'individual',
        'external_account[routing_number]':
            shopController.routingNumberController.text,
        'external_account[account_number]':
            shopController.accountNumberController.text,
        'tos_acceptance[date]':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        'tos_acceptance[ip]': currentIP.toString(),
        'business_type': 'individual',
        'business_profile[mcc]': '5734',
        'business_profile[url]': 'www.google.com',
        'company[address][city]': shopController.accountCity.value,
        'company[address][country]': 'US',
        'company[address][state]': shopController.accountState.value,
        'company[address][line1]': shopController.addressController.text,
        'company[address][line2]': shopController.addressController.text,
        'company[address][postal_code]':
            shopController.postalCodeController.text,
        'company[name]': shopController.firstNameController.text,
        'company[phone]': shopController.phoneNumberController.text,
        'individual[address][postal_code]':
            shopController.postalCodeController.text,
        'individual[address][city]': shopController.accountCity.value,
        'individual[address][country]': 'US',
        'individual[address][state]': shopController.accountState.value,
        'individual[address][line1]': shopController.addressController.text,
        'individual[address][line2]': '',
        'individual[first_name]': shopController.firstNameController.text,
        'individual[last_name]': shopController.lastNameController.text,
        'individual[phone]': shopController.phoneNumberController.text,
        'individual[ssn_last_4]': shopController.ssnNumberController.text,
        'individual[email]': Get.find<AuthController>().usermodel.value!.email!,
        'individual[dob][day]': birthDate.day.toString(),
        'individual[dob][month]': birthDate.month.toString(),
        'individual[dob][year]': birthDate.year.toString()
      };

      var account = await DbBase().databaseRequest(
          stripeAccounts, DbBase().postRequestType,
          bodyFields: data,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': "Bearer $stripeSecretKey"
          });

      Get.back();

      if (jsonDecode(account)["external_accounts"] != null &&
          jsonDecode(account)["external_accounts"]["data"] != null) {
        var id = jsonDecode(account)["id"];
        userStripeAccountId.value = id;
        Get.find<AuthController>().usermodel.refresh();

        await UserAPI().updateUser({
          "stripeAccountId": userStripeAccountId.value,
          "stripeBankAccount": jsonDecode(account)["external_accounts"]["data"]
              [0]['id']
        }, Get.find<AuthController>().usermodel.value!.id!);

        Get.back();
        const GetSnackBar(
          message: successfully_connected_your_account,
          duration: Duration(seconds: 3),
        ).show();
      } else {
        const GetSnackBar(
          message: did_not_connect_account,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ).show();
      }
    } catch (e, s) {
      printOut("$e $s");
    } finally {
      creatingStripeAccount.value = false;
      shopController.firstNameController.text = "";
      shopController.lastNameController.text = "";
      shopController.routingNumberController.text = "";
      shopController.accountNumberController.text = "";
      shopController.addressController.text = "";
      shopController.ssnNumberController.text = "";
      shopController.postalCodeController.text = "";
      shopController.accountNumberController.text = "";
    }
  }

  withdraw(StripeAccount stripeAccountModel) async {
    try {
      withdrawing.value = true;
      int amount = int.parse(withdrawAmountController.text);

      if (amount <=
          Get.find<AuthController>().usermodel.value!.wallet!.toInt()) {
        Get.defaultDialog(
            title: just_a_moment,
            content: const CircularProgressIndicator(),
            barrierDismissible: false);

        String total = (amount * 100).toString();
        var payout = await TransactionAPI().withdrawToBank(
          total,
        );

        if (payout["id"] != null) {
          showDialog(
              context: Get.context!,
              builder: (context) {
                return Dialog(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(10.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: Styles.greenTheme,
                            size: 45,
                          ),
                          SizedBox(height: 0.01.sh),
                          Text(
                            success,
                            style:
                                TextStyle(color: primarycolor, fontSize: 18.sp),
                          ),
                          SizedBox(height: 0.01.sh),
                          Text(
                            withdraw_request_is_being_processed,
                            style:
                                TextStyle(color: primarycolor, fontSize: 14.sp),
                          ),
                          SizedBox(height: 0.02.sh),
                          InkWell(
                            onTap: () {
                              withdrawAmountController.clear();
                              Get.offAll(MainPage());
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                okay,
                                style: TextStyle(
                                    color: primarycolor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        } else {
          const GetSnackBar(
            message: something_went_wrong_try,
            duration: Duration(seconds: 3),
          ).show();
        }
      } else {
        GetSnackBar(
          message: "$insufficient_balance_to_withdraw \$${amount.toString()}",
          duration: const Duration(seconds: 3),
        ).show();
      }
    } catch (e) {
      Get.back();
    } finally {
      withdrawing.value = false;
    }
  }
}
