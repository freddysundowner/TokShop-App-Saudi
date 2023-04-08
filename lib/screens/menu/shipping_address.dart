import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/screens/menu/address_details_form.dart';
import 'package:tokshop/screens/menu/components/address_short_details_card.dart';
import 'package:tokshop/utils/text.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/shop_controller.dart';

class ShippingAddress extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  final ShopController shopController = Get.find<ShopController>();

  final String socialLinkError = '';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController twitterController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();

  ShippingAddress({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    userController.gettingMyAddrresses();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
           shipping_address,
        ),
      ),
      body: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                     shipping_address,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                    InkWell(
                      child: const Icon(Icons.edit),
                      onTap: () {
                        Get.to(() => AddressDetailsForm(
                              addressToEdit:
                                  userController.myAddresses.isNotEmpty
                                      ? userController.myAddresses[0]
                                      : null,
                              showsave: true,
                            ));
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (userController.myAddresses.isNotEmpty)
                  AddressShortDetailsCard(
                    address: userController.myAddresses[0],
                    onTap: () {},
                  ),
                if (userController.myAddresses.isEmpty)
                  const Text(your_address)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
