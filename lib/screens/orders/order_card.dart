import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/functions.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/product_image.dart';

import '../../utils/text.dart';

//ignore: must_be_immutable
class OrderCard extends StatelessWidget {
  Order ordersModel;
  OrderCard({Key? key, required this.ordersModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ordersModel.itemId!.productId == null
        ? Container()
        : Card(
            elevation: 3,
            shadowColor: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primarycolor),
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                            child: ProductImage(
                          element:
                              ordersModel.itemId!.productId!.images!.isNotEmpty
                                  ? ordersModel.itemId!.productId!.images![0]
                                  : "",
                          size: 60,
                        )),
                      ),
                    ),
                    SizedBox(
                      width: 0.02.sw,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ordersModel.itemId!.productId!.name!,
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          // Text(
                          //   "${ordersModel.shippingId!.name!} | ${ordersModel.shippingId!.addrress1!}, ${ordersModel.shippingId!.city!}",
                          //   style: TextStyle(
                          //       color: primarycolor, fontSize: 11.sp),
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "$payment_method: ",
                                style: TextStyle(
                                    color: primarycolor, fontSize: 11.sp),
                              ),
                              Text(
                                ordersModel.getPaymentMethod()!,
                                style: TextStyle(
                                    color: primarycolor, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$created_on: ${convertTime(ordersModel.date.toString())}",
                        style: TextStyle(fontSize: 11.sp, color: primarycolor),
                      ),
                      Text(
                        "$order_no.${ordersModel.invoice}",
                        style: TextStyle(fontSize: 11.sp, color: primarycolor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  thickness: 1,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                         total,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          Text(
                            currencySymbol + ordersModel.totalCost!.toString(),
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            service_fee,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          Text(
                            currencySymbol + ordersModel.servicefee.toString(),
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            qty,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          Text(
                            ordersModel.itemId!.quantity.toString(),
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            shipping_fee,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          Text(
                            currencySymbol + ordersModel.shippingFee.toString(),
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            status,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          Text(
                            ordersModel.status!,
                            style: TextStyle(
                                color: ordersModel.status == "processing" ||
                                        ordersModel.status == "pending"
                                    ? Colors.amber
                                    : ordersModel.status == "cancelled"
                                        ? Colors.red
                                        : primarycolor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
