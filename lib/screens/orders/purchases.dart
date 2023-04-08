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

class Purchases extends StatelessWidget {
  final UserController _userController = Get.find<UserController>();
  final OrderController _orderController = Get.put(OrderController());

  Purchases({Key? key}) : super(key: key) {
    _userController.getUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    _userController.userOrdersPageNumber.value = 1;
    return RefreshIndicator(
      onRefresh: () async {
        await _userController.getUserOrders();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(purchases),
        ),
        body: PurchasesWidget(),
      ),
    );
  }
}

class PurchasesWidget extends StatelessWidget {
  PurchasesWidget({
    super.key,
  }) {
    _userController.getUserOrders();
  }

  final UserController _userController = Get.find<UserController>();
  final OrderController _orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _userController.ordersLoading.isFalse
          ? _userController.userOrders.isNotEmpty
              ? ListView.builder(
                  controller: _userController.userOrdersScrollController,
                  itemCount: _userController.userOrders.length,
                  itemBuilder: (context, index) {
                    Order ordersModel = _userController.userOrders[index];
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
              : Text(
                  no_purchases_yet,
                  style: TextStyle(color: primarycolor, fontSize: 16.sp),
                )
          : const Center(
              child: CircularProgressIndicator(
                color: primarycolor,
              ),
            );
    });
  }
}
