import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/screens/auth/select_interests.dart';

import '../../connection_error.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user.dart';
import '../../services/user_api.dart';
import '../../utils/utils.dart';
import 'welcome_screen.dart';
import '../home/main_page.dart';

class HandleAuthPage extends StatefulWidget {
  const HandleAuthPage({Key? key}) : super(key: key);

  @override
  State<HandleAuthPage> createState() => _HandleAuthPageState();
}

class _HandleAuthPageState extends State<HandleAuthPage> {
  final AuthController authController = Get.put(AuthController());
  final ShopController shopController = Get.put(ShopController());
  final ProductController productController = Get.put(ProductController());
  final TokShowController tokShowController = Get.put(TokShowController());

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const WelcomeScreen();
    } else {
      return FutureBuilder(
        future: UserAPI.getUserById(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData == true) {
            authController.usermodel.value = snapshot.data as UserModel?;
            authController.usermodel.refresh();
            if (authController.usermodel.value!.payoutMethod != null) {
              authController.getConnectedStripeBanks();
            }
            authController.callInit();
            if (authController.usermodel.value!.interests.isEmpty) {
              return SelectInterests();
            }
            return MainPage();
          }
          if (authController.connectionstate.value == false) {
            return ConnectionFailed();
          }
          return ConnectionFailed();
        },
      );
    }
  }
}
