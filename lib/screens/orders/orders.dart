import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/orders/order_card.dart';
import 'package:tokshop/utils/styles.dart';

import '../../controllers/order_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/order.dart';

import '../../utils/text.dart';
import 'order_receipt.dart';

class Orders extends StatelessWidget {
  final UserController _userController = Get.find<UserController>();

  Orders({Key? key}) : super(key: key) {
    _userController.getOrders(
        "shopId=${_userController.currentProfile.value.shopId?.id!}");
  }

  @override
  Widget build(BuildContext context) {
    _userController.shopOrdersPageNumber.value = 1;
    return RefreshIndicator(
      onRefresh: () async {
        await _userController.getOrders();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(orders),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: OrdersWidget(),
        ),
      ),
    );
  }
}

class OrdersWidget extends StatelessWidget {
  OrdersWidget({Key? key}) : super(key: key) {
    _userController.getOrders(
        "shopId=${_userController.currentProfile.value.shopId?.id!}");
  }

  final OrderController _orderController = Get.find<OrderController>();
  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() {
        if (_userController.ordersLoading.isTrue) {
          return const Center(
            child: CircularProgressIndicator(
              color: primarycolor,
            ),
          );
        }
        if (_userController.shopOrders.isEmpty) {
          return Container(
            margin: const EdgeInsets.only(top: 50),
            child: Text(you_have_no_orders_yet,
                style: TextStyle(color: primarycolor, fontSize: 16.sp)),
          );
        }
        return _userController.shopOrders.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                controller: _userController.shopOrdersScrollController,
                itemCount: _userController.shopOrders.length,
                itemBuilder: (context, index) {
                  Order ordersModel = _userController.shopOrders[index];

                  return InkWell(
                    onTap: () {
                      _orderController.currentOrder.value = ordersModel;
                      Get.to(OrderReceipt(ordersModel));
                    },
                    child: OrderCard(
                      ordersModel: ordersModel,
                    ),
                  );
                })
            : const Center(
                child: CircularProgressIndicator(
                  color: primarycolor,
                ),
              );
      }),
    );
  }
}
