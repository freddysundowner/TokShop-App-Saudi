import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/screens/checkout/payment_methods/stripe_setup.dart';

import '../../utils/text.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class PayoutSettings extends StatelessWidget {
  PayoutSettings({Key? key}) : super(key: key);
  UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    if (authController.usermodel.value!.payoutMethod != null) {
      authController.getConnectedStripeBanks();
    }
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.clear,
            color: primarycolor,
          ),
        ),
        title: const Text(payout_settings),
      ),
      body: Obx(
        () => authController.deletingStripeBankAccounts.isTrue
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      if (authController.usermodel.value!.payoutMethod ==
                          null) {
                        Get.to(() => StripeSetup());
                      } else {}
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authController.usermodel.value!.payoutMethod ==
                                        null
                                    ? connect_bank_account
                                    : connected_payout_bank,
                                style: TextStyle(
                                    color: primarycolor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                want_to_get_paid,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                  if (authController.userStripeAccountData.isNotEmpty)
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor: Colors.white,
                      ),
                      child: Padding(
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 10.0),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                            child: ListView(
                              children: authController.userStripeAccountData
                                  .map((element) => InkWell(
                                        onTap: () async {
                                          var response = await authController
                                              .deleteStripeBankAccount();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "$bank_name: ${element.bankName}"),
                                                Text(
                                                    "$account_holder_name: ${element.accountHolderName}"),
                                                Text(
                                                    "$last_4_digits: ${element.last4}"),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {},
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            )
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          )),
                    ),
                  const Divider(
                    color: primarycolor,
                    thickness: 0.2,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connect_paypay,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              coming_soon,
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: primarycolor,
                    thickness: 0.2,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connect_mpesa,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              coming_soon,
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: primarycolor,
                    thickness: 0.2,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connect_flutterwave,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              coming_soon,
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
