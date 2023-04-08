import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/orders/product_review_dialog.dart';
import 'package:tokshop/screens/profile/profile_all_products.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/utils/text.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/order.dart';
import '../../services/notifications_api.dart';
import '../../services/orders_api.dart';
import '../../services/user_api.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class OrderReceipt extends StatelessWidget {
  Order ordersModel;
  final OrderController _orderController = Get.put(OrderController());
  final UserController _userController = Get.find<UserController>();
  final ShopController _shopController = Get.find<ShopController>();

  OrderReceipt(this.ordersModel, {Key? key}) : super(key: key) {
    getOrder();
  }

  getOrder() async {
    if (ordersModel.id != null) {
      _orderController.currentOrderLoading.value = true;
      var order = await UserAPI().getOrderById(ordersModel.id!);
      ordersModel = Order.fromJson(order);
      _orderController.currentOrder.value = ordersModel;
      _orderController.currentOrder.refresh();
      _orderController.currentOrderLoading.value = false;
      _orderController
          .getProductReviewWithID(ordersModel.itemId!.productId!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              "$order_no. #${_orderController.currentOrder.value.invoice ?? ""}",
              style:
                  TextStyle(color: primarycolor, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: false,
        ),
        body: Obx(() {
          return _orderController.currentOrderLoading.isFalse
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primarycolor),
                            margin: const EdgeInsets.all(10),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Center(
                                  child: ordersModel
                                          .itemId!.productId!.images!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: ordersModel
                                              .itemId!.productId!.images!.first,
                                          height: 0.08.sh,
                                          width: 0.2.sw,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(imageplaceholder),
                                        )
                                      : Image.asset(
                                          imageplaceholder,
                                          height: 0.1.sh,
                                          width: 0.2.sw,
                                          fit: BoxFit.fill,
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
                                Text(
                                  "$qty: ${ordersModel.quantity}",
                                  style: TextStyle(
                                      color: primarycolor, fontSize: 11.sp),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Styles.textButton.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item_total,
                              style: TextStyle(
                                  color: primarycolor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$currencySymbol ${ordersModel.subTotal!.toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: primarycolor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                            color: Styles.textButton.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  subtotal,
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$currencySymbol ${ordersModel.subTotal!.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  shipping_method,
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ordersModel
                                              .getShippingMethod(
                                                  ordersModel.shippingMethd)
                                              .name !=
                                          "Free"
                                      ? "${ordersModel.getShippingMethod(ordersModel.shippingMethd).name} $currencySymbol${ordersModel.getShippingMethod(ordersModel.shippingMethd).amount}"
                                      : ordersModel
                                          .getShippingMethod(
                                              ordersModel.shippingMethd)
                                          .name,
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Divider(
                              color: primarycolor,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  total,
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$currencySymbol ${ordersModel.totalCost!.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$status: ",
                              style: TextStyle(
                                  color: primarycolor, fontSize: 13.sp),
                            ),
                            Obx(() {
                              return Expanded(
                                child: Text(
                                  _orderController.currentOrder.value.status
                                      .toString()
                                      .capitalizeFirst!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: _orderController.currentOrder.value
                                                    .status ==
                                                "processing" ||
                                            _orderController.currentOrder.value
                                                    .status ==
                                                "pending"
                                        ? Colors.amber
                                        : _orderController.currentOrder.value
                                                    .status ==
                                                "cancelled"
                                            ? Colors.red
                                            : primarycolor,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipping_address_info,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "$address_one: ${ordersModel.shippingId!.addrress1!},\n$address_two: ${ordersModel.shippingId!.addrress2!},\n$city: ${ordersModel.shippingId!.city!},\n$state: ${ordersModel.shippingId!.state!},\n$phone: ${ordersModel.shippingId!.phone!}",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 0.02.sh,
                      ),
                      ordersModel.shopId ==
                              Get.find<AuthController>()
                                  .usermodel
                                  .value!
                                  .shopId!
                                  .id
                          ? Obx(() {
                              return (_orderController
                                              .currentOrder.value.status !=
                                          "completed" &&
                                      _orderController
                                              .currentOrder.value.status !=
                                          "cancelled")
                                  ? InkWell(
                                      onTap: () {
                                        showUpdateOrderStatusBottomSheet(
                                            context);
                                      },
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              height: 40,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0, bottom: 5),
                                                child: Center(
                                                    child: Text(
                                                  update_status,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13.sp),
                                                )),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 0.04.sh,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container();
                            })
                          : Obx(() {
                              return (_orderController
                                          .currentOrder.value.status ==
                                      "completed")
                                  ? InkWell(
                                      onTap: () {
                                        Get.defaultDialog(
                                            title: mark_as_completed,
                                            middleText: sure_mark_as_completed,
                                            onConfirm: () {
                                              Get.back();
                                              // Get.back();
                                              updateStatus("completed");
                                            },
                                            textConfirm: yes,
                                            textCancel: no);
                                      },
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 0.8.sw,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0, bottom: 5),
                                                child: Center(
                                                    child: Text(
                                                  mark_as_completed,
                                                  style: TextStyle(
                                                      fontSize: 13.sp),
                                                )),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 0.04.sh,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container();
                            }),
                      ordersModel.itemId!.productId!.ownerId!.shopId!.id ==
                              Get.find<AuthController>()
                                  .usermodel
                                  .value!
                                  .shopId!
                                  .id
                          ? InkWell(
                              onTap: () {
                                _userController.getUserProfile(
                                    ordersModel.customerId!.id!);
                                Get.to(UserProfile());
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Text(
                                      customer_details,
                                      style: TextStyle(
                                          color: primarycolor, fontSize: 13.sp),
                                    ),
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: 0.94.sw,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: ordersModel
                                                          .itemId!
                                                          .productId!
                                                          .ownerId!
                                                          .profilePhoto !=
                                                      ""
                                                  ? Image.network(
                                                      ordersModel
                                                          .itemId!
                                                          .productId!
                                                          .ownerId!
                                                          .profilePhoto!,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.fill,
                                                      errorBuilder: (context,
                                                              object,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        imageplaceholder,
                                                        height: 40,
                                                        width: 40,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    )
                                                  : Image.asset(
                                                      imageplaceholder,
                                                      height: 40,
                                                      width: 40,
                                                      fit: BoxFit.fill,
                                                    ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 0.01.sw,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "$name: ",
                                                        style: TextStyle(
                                                            fontSize: 13.sp),
                                                      ),
                                                      SizedBox(
                                                        width: 0.03.sw,
                                                      ),
                                                      Text(
                                                        "${ordersModel.customerId!.firstName} ${ordersModel.customerId!.lastName}",
                                                        overflow:
                                                            TextOverflow.clip,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                            color: Styles
                                                                .dullGreyColor,
                                                            fontSize: 13.sp),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "$userName: ",
                                                        style: TextStyle(
                                                            fontSize: 13.sp),
                                                      ),
                                                      SizedBox(
                                                        width: 0.03.sw,
                                                      ),
                                                      SizedBox(
                                                        width: 0.35.sw,
                                                        child: Text(
                                                          "${ordersModel.customerId!.userName}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              color: Styles
                                                                  .dullGreyColor,
                                                              fontSize: 13.sp),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 0.02.sh,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                _shopController.currentShop.value = ordersModel
                                    .itemId!.productId!.ownerId!.shopId!;
                                Get.to(() => ProfileProducts(
                                      userid: ordersModel
                                          .itemId!.productId!.ownerId!.id!,
                                    ));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 0.02.sh,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Text(
                                      "$product_by: ${ordersModel.itemId!.productId!.ownerId!.shopId!.name}",
                                      style: TextStyle(
                                          color: primarycolor, fontSize: 13.sp),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0.02.sh,
                                  ),
                                ],
                              ),
                            ),
                      _orderController.loadingReview.isTrue
                          ? const Center(child: CircularProgressIndicator())
                          : _orderController.curentProductUserReview.value !=
                                  null
                              ? Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_orderController
                                          .curentProductUserReview
                                          .value!
                                          .feedback!),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      RatingBarIndicator(
                                        rating: _orderController
                                            .curentProductUserReview
                                            .value!
                                            .rating
                                            .toDouble(),
                                        itemCount: 5,
                                        itemSize: 10.0,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ProductReviewDialog(
                                            order: ordersModel,
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      give_product_review,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: primarycolor,
                  ),
                );
        }));
  }

  Future<dynamic> showUpdateOrderStatusBottomSheet(BuildContext context) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: 0.52,
              expand: false,
              builder: (BuildContext productContext,
                  ScrollController scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          height: 0.01.sh,
                          width: 0.15.sw,
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        SizedBox(
                          height: 0.02.sh,
                        ),
                        Text(
                          udate_order_status,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        SizedBox(
                          height: 0.01.sh,
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                updateOrderStatus("pending");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pending,
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                  Obx(() {
                                    return Radio(
                                      activeColor: kPrimaryColor,
                                      value: _orderController
                                                  .currentOrder.value.status ==
                                              "pending"
                                          ? false
                                          : true,
                                      onChanged: (e) {
                                        if (e == true) {
                                          updateOrderStatus("pending");
                                        }
                                      },
                                      groupValue: false,
                                    );
                                  })
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                updateOrderStatus("processing");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    processing,
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                  Obx(() {
                                    return Radio(
                                      activeColor: kPrimaryColor,
                                      value: _orderController
                                                  .currentOrder.value.status ==
                                              "processing"
                                          ? false
                                          : true,
                                      onChanged: (e) {
                                        if (e == true) {
                                          updateOrderStatus("processing");
                                        }
                                      },
                                      groupValue: false,
                                    );
                                  })
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                updateOrderStatus("completed");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    completed,
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                  Obx(() {
                                    return Radio(
                                      activeColor: kPrimaryColor,
                                      value: _orderController
                                                  .currentOrder.value.status ==
                                              "completed"
                                          ? false
                                          : true,
                                      onChanged: (e) {
                                        if (e == true) {
                                          updateOrderStatus("completed");
                                        }
                                      },
                                      groupValue: false,
                                    );
                                  })
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                updateOrderStatus("cancelled");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cancelled,
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                  Obx(() {
                                    return Radio(
                                      activeColor: kPrimaryColor,
                                      value: _orderController
                                                  .currentOrder.value.status ==
                                              "cancelled"
                                          ? false
                                          : true,
                                      onChanged: (e) {
                                        if (e == true) {
                                          updateOrderStatus("cancelled");
                                        }
                                      },
                                      groupValue: false,
                                    );
                                  })
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        });
      },
    );
  }

  updateOrderStatus(String status) async {
    Get.defaultDialog(
        title: update_order_status,
        middleText: "$sure_to_update_order_status $status?",
        onConfirm: () {
          Get.back();
          Get.back();
          updateStatus(status);
        },
        textConfirm: yes,
        radius: 8,
        buttonColor: kPrimaryColor,
        textCancel: no);
  }

  Future<void> updateStatus(String status) async {
    _orderController.currentOrder.value.status = status;
    _orderController.currentOrder.refresh();

    var notificationMessage = "Your order status for "
        "${_orderController.currentOrder.value.itemId!.productId!.name} "
        "has been updated to $status";

    OrderApi().updateOrder({
      "status": status,
      "shopId":
          _orderController.currentOrder.value.itemId!.productId!.shopId!.id
    }, ordersModel.id!).then((value) async {
      if (status == "cancelled") {
        notificationMessage = "Your order for "
            "${_orderController.currentOrder.value.itemId!.productId!.name} "
            "has been cancelled. We have sent you a refund";
        await OrderApi().cancelAnOrder(ordersModel.id!);
      } else if (status == "delivered") {
        await OrderApi().finishAnOrder(ordersModel.id!);
      }
    });

    if (status == "cancelled") {
      notificationMessage = "Your order for "
          "${_orderController.currentOrder.value.itemId!.productId!.name} "
          "has been cancelled. We have sent you a refund";
    }

    await NotificationsAPI().sendNotification(
        [_orderController.currentOrder.value.customerId!.id],
        "Order update",
        notificationMessage,
        "OrderScreen",
        _orderController.currentOrder.value.id!);

    var activityBody = {
      "imageurl": null,
      "name": "Order update",
      "type": "OrderScreen",
      "actionkey": _orderController.currentOrder.value.id!,
      "actioned": false,
      'to': _orderController.currentOrder.value.customerId!.id,
      'from': Get.find<AuthController>().currentuser!.id,
      "message": notificationMessage,
      "time": DateTime.now().millisecondsSinceEpoch,
    };
    await NotificationsAPI().saveActivity(activityBody);
  }
}
