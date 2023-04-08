import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';

import '../../controllers/order_controller.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import 'orders.dart';
import 'purchases.dart';

class OrdersHistory extends StatelessWidget {
  final OrderController _orderController = Get.put(OrderController());
  final AuthController authController = Get.put(AuthController());

  OrdersHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: authController.usermodel.value!.shopId != null ? 2 : 1,
      initialIndex: _orderController.tabIndex.value,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            orders_history,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
            ),
          ),
          bottom: TabBar(
            labelColor: kPrimaryColor,
            indicatorColor: kPrimaryColor,
            unselectedLabelColor: primarycolor,
            tabs: [
              const Tab(
                text: your_orders,
              ),
              if (authController.usermodel.value!.shopId != null)
                const Tab(
                  text: shop_orders,
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Purchases(),
            if (authController.usermodel.value!.shopId != null) Orders(),
          ],
        ),
      ),
    );
  }
}
