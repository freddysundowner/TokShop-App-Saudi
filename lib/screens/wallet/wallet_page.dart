import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/checkout/payment_methods/stripe_setup.dart';
import 'package:tokshop/screens/wallet/transations_page.dart';
import 'package:tokshop/screens/wallet/withdraw_page.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

class WalletPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final WalletController _walletController = Get.put(WalletController());

  WalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (authController.usermodel.value!.payoutMethod != null) {
      authController.getAccountBalances();
      authController.getConnectedStripeBanks();
    }
    return Scaffold(
      backgroundColor: const Color(0Xfff4f5fa),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          wallet,
          style: TextStyle(
            fontSize: 18.0.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: primarycolor),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _walletController.getUserTransactions();
          _walletController.filterTransactions();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  margin: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primarycolor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        balance,
                        style: TextStyle(color: primarycolor, fontSize: 14.sp),
                      ),
                      Obx(() {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "\$${authController.currentuser!.wallet}",
                              style: TextStyle(
                                  color: primarycolor,
                                  fontSize: 41.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (authController.currentuser!.pendingWallet !=
                                    null &&
                                authController.currentuser!.pendingWallet! > 0)
                              Text(
                                " + ${authController.currentuser!.pendingWallet} $pending",
                                style: TextStyle(
                                    color: primarycolor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Spacer(),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authController.gettingStripeBankAccounts.isTrue
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : authController.userStripeAccountData.isEmpty
                          ? Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => StripeSetup());
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text(
                                          connect_bank,
                                          style: TextStyle(
                                              fontSize: 21,
                                              color: primarycolor),
                                        ),
                                        Icon(
                                          Icons.add_circle_outline_outlined,
                                          color: primarycolor,
                                          size: 30,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Divider()
                              ],
                            )
                          : Theme(
                              data: ThemeData(
                                unselectedWidgetColor: primarycolor,
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    child: ListView(
                                      children:
                                          authController.userStripeAccountData
                                              .map((element) => Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Get.to(() => WithdrawPage(
                                                              stripeAccountModel:
                                                                  element));
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              bank_account,
                                                              style: TextStyle(
                                                                  fontSize: 21,
                                                                  color:
                                                                      primarycolor),
                                                            ),
                                                            Text(
                                                                "$bank_name: ${element.bankName}"),
                                                            Text(
                                                                "$account_holder: ${element.accountHolderName}"),
                                                          ],
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        color: primarycolor,
                                                      )
                                                    ],
                                                  ))
                                              .toList(),
                                    ),
                                  )),
                            ),
                  InkWell(
                    onTap: () {
                      Get.to(() => Transactions());
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            transaction_history,
                            style: TextStyle(color: primarycolor, fontSize: 21),
                          ),
                          Icon(Icons.arrow_forward_ios, color: primarycolor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkStripeStatus(
      BuildContext context, String clientSecret, String amount) async {
    await Stripe.instance
        .retrievePaymentIntent(clientSecret)
        .then((value) async {
      if (value.status.name == "Succeeded") {
        // await updateWallet(amount.toString());
        return true;
      } else if (value.status.name == "requires_payment_method") {
        await checkStripeStatus(context, clientSecret, amount);
      } else if (value.status.name == "requires_confirmation") {
        await checkStripeStatus(context, clientSecret, amount);
      } else if (value.status.name == "requires_action") {
        await checkStripeStatus(context, clientSecret, amount);
      } else if (value.status.name == "processing") {
        await checkStripeStatus(context, clientSecret, amount);
      }
    });
  }
}
