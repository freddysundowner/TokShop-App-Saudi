import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/screens/checkout/checkout_screen.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/room/create_show_dialog.dart';
import 'package:tokshop/utils/styles.dart';

import '../../../utils/text.dart';

class AddToCartFAB extends StatelessWidget {
  AddToCartFAB({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  final CheckOutController checkOutController = Get.find<CheckOutController>();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: kPrimaryColor,
      onPressed: () async {
        if (product.ownerId!.id == FirebaseAuth.instance.currentUser!.uid) {
          homeController.createRoomView(title: product.name!, product: product);
        } else {
          checkOutController.product.value = product;
          checkOutController.qty.value = 1;
          if (checkOutController.selectetedvariationvalue.value == "" &&
              product.variations!.isNotEmpty) {
            checkOutController.selectetedvariationvalue.value =
                product.variations![0];
          }
          checkOutController.tabController.value!.animateTo(0);
          checkOutController.tabIndex.value = 0;
          Get.to(() => CheckOut());
        }
      },
      label: Text(
        product.ownerId!.id == FirebaseAuth.instance.currentUser!.uid
            ? go_live_now
            : buy_now,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      icon: product.ownerId!.id == FirebaseAuth.instance.currentUser!.uid
          ? const Icon(
              Icons.mic,
            )
          : const Icon(
              Icons.shopping_cart,
            ),
    );
  }
}
