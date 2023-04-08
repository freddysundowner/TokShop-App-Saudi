import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/stripe_account.dart';

import '../../controllers/wallet_controller.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

//ignore: must_be_immutable
class WithdrawPage extends StatelessWidget {
  StripeAccount? stripeAccountModel;
  WithdrawPage({
    Key? key,
    this.stripeAccountModel,
  }) : super(key: key);

  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          withdraw,
          style: TextStyle(
            fontSize: 18.0.sp,
          ),
        ),
      ),
      body: SizedBox(
        width: 1.sw,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(children: [
                SizedBox(
                  height: 0.1.sh,
                ),
                const Text(
                  how_much_do_you_want,
                  style: TextStyle(fontSize: 16, color: primarycolor),
                ),
                SizedBox(
                  height: 0.02.sh,
                ),
                Container(
                  width: 0.9.sw,
                  decoration: BoxDecoration(
                      color: Styles.textButton.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    controller: _walletController.withdrawAmountController,
                    autofocus: true,
                    maxLength: null,
                    maxLines: null,
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 0.1.sh,
                ),
                SizedBox(
                  width: 0.9.sw,
                  child: Obx(() {
                    return _walletController.withdrawing.isFalse
                        ? DefaultButton(
                            text:withdraw,
                            press: () async {
                              int amount = int.parse(_walletController
                                  .withdrawAmountController.text);

                              if (amount > 0) {
                                _walletController.withdraw(stripeAccountModel!);
                              } else {
                                const GetSnackBar(
                                  message: amount_has_to_be_greater,
                                  duration: Duration(seconds: 3),
                                ).show();
                              }
                            })
                        : const Center(
                            child: CircularProgressIndicator(
                            color: primarycolor,
                          ));
                  }),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
