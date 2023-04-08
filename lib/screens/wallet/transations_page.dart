import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/controllers/wallet_controller.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/screens/orders/order_receipt.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';

import '../../models/transaction.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

class Transactions extends StatelessWidget {
  Transactions({Key? key}) : super(key: key);

  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transactions_history),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 0.003.sh,
              ),
              InkWell(
                onTap: () {
                  showFilterBottomSheet(
                      context,
                      Obx(
                        () => Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 0.03.sh,
                              ),
                              Text(
                                filter_by_status,
                                style: TextStyle(
                                    color: primarycolor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w300),
                              ),
                              Theme(
                                data: ThemeData(
                                  //here change to your color
                                  unselectedWidgetColor: primarycolor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          filterTransaction("");
                                        },
                                        child: Row(
                                          children: [
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: _walletController
                                                          .transactionFilter
                                                          .value ==
                                                      ""
                                                  ? false
                                                  : true,
                                              groupValue: false,
                                              onChanged: (v) {
                                                filterTransaction("");
                                              },
                                            ),
                                            Text(
                                             all,
                                              style: TextStyle(
                                                  color: primarycolor,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 0.01.sh,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          filterTransaction("Pending");
                                        },
                                        child: Row(
                                          children: [
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: _walletController
                                                          .transactionFilter
                                                          .value ==
                                                      "Pending"
                                                  ? false
                                                  : true,
                                              groupValue: false,
                                              onChanged: (v) {
                                                filterTransaction("Pending");
                                              },
                                            ),
                                            Text(
                                              pending,
                                              style: TextStyle(
                                                  color: primarycolor,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 0.01.sh,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          filterTransaction("Completed");
                                        },
                                        child: Row(
                                          children: [
                                            Radio(
                                              activeColor: kPrimaryColor,
                                              value: _walletController
                                                          .transactionFilter
                                                          .value ==
                                                      "Completed"
                                                  ? false
                                                  : true,
                                              groupValue: false,
                                              onChanged: (v) {
                                                filterTransaction("Completed");
                                              },
                                            ),
                                            Text(
                                             completed,
                                              style: TextStyle(
                                                  color: primarycolor,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.filter_list_sharp,
                      color: primarycolor,
                    ),
                    Text(
                      filter,
                      style: TextStyle(
                          color: primarycolor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 0.01.sh,
              ),
              Obx(() {
                return _walletController.transactionsLoading.isFalse
                    ? _walletController.filteredTransactionsList.isNotEmpty
                        ? Column(
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  controller: _walletController
                                      .transactionScrollController,
                                  itemCount: _walletController
                                      .filteredTransactionsList.length,
                                  itemBuilder: (context, index) {
                                    Transaction transaction =
                                        Transaction.fromJson(_walletController
                                            .filteredTransactionsList
                                            .elementAt(index));
                                    return GestureDetector(
                                      onTap: () {
                                        if (transaction.type == "gift") {
                                          var uid = transaction.from!.id;
                                          Get.find<UserController>()
                                              .getUserProfile(uid!);
                                          Get.to(() => UserProfile());
                                        } else if (transaction.type ==
                                            "sending") {
                                          var uid = transaction.from!.id;
                                          Get.find<UserController>()
                                              .getUserProfile(uid!);
                                          Get.to(() => UserProfile());
                                        } else if (transaction.type ==
                                            "order") {
                                          if (transaction.orderId != "") {
                                            print(transaction.orderId);
                                            Get.to(
                                              () => OrderReceipt(Order(
                                                  id: transaction.orderId)),
                                            );
                                          }
                                        } else if (transaction.type ==
                                            "purchase") {
                                          if (transaction.orderId != "") {
                                            Get.put(OrderController());
                                            Get.to(
                                              () => OrderReceipt(
                                                Order(id: transaction.orderId),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 15.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Styles.textButton
                                                .withOpacity(0.25)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    convertTime(transaction.date
                                                        .toString()),
                                                    style: TextStyle(
                                                        color: Styles
                                                            .dullGreyColor,
                                                        fontSize: 10.sp),
                                                  ),
                                                  if (transaction.status ==
                                                      "Pending")
                                                    const Icon(
                                                      CupertinoIcons
                                                          .exclamationmark_circle,
                                                      color: Styles.red,
                                                      size: 15,
                                                    )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      transaction.type == "gift"
                                                          ? "${transaction.reason} -- ${transaction.from!.firstName!}"
                                                          : transaction.reason,
                                                      style: TextStyle(
                                                        color: primarycolor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14.sp,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$ ${transaction.deducting == true ? "-" : "+"}${transaction.amount}",
                                                    style: TextStyle(
                                                        color: transaction
                                                                    .deducting ==
                                                                true
                                                            ? Colors.red
                                                            : Colors.green,
                                                        fontSize: 13.sp),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              _walletController.moreTransactionsLoading.isTrue
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                      color: primarycolor,
                                    ))
                                  : Container(),
                            ],
                          )
                        : Center(
                            child: Text(
                              no_transactions_yet,
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 16.sp),
                            ),
                          )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: primarycolor,
                        ),
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }

  filterTransaction(String status) {
    Get.back();
    _walletController.transactionFilter.value = status;

    _walletController.filterTransactions();
  }
}
