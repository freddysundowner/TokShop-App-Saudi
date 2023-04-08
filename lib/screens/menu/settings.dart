import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/utils/text.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../services/shop_api.dart';
import '../../services/user_api.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class AccountSettings extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  final ShopController shopController = Get.find<ShopController>();

  final String socialLinkError = '';

  final TextEditingController twitterController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();

  AccountSettings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    userController.gettingMyAddrresses();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          settings,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration:
                    BoxDecoration(color: Styles.textButton.withOpacity(0.25)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              direct_messages,
                              style: TextStyle(
                                  color: primarycolor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              turn_this_on,
                              style: TextStyle(fontSize: 11.sp),
                            ),
                          ],
                        ),
                        Obx(() {
                          return Switch(
                              activeColor: kPrimaryColor,
                              value: authController
                                  .usermodel.value!.receivemessages!,
                              onChanged: (value) async {
                                authController
                                    .usermodel.value!.receivemessages = value;
                                authController.usermodel.refresh();
                                await userController
                                    .updateUser({"receivemessages": value});
                              });
                        })
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              Container(
                width: 0.9.sw,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Styles.textButton.withOpacity(0.25)),
                child: InkWell(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return Dialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Container(
                              height: 0.3.sh,
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.block,
                                      color: kPrimaryColor,
                                      size: 45,
                                    ),
                                    SizedBox(height: 0.03.sh),
                                    Obx(() {
                                      return Text(
                                        Get.find<AuthController>()
                                                    .usermodel
                                                    .value!
                                                    .accountDisabled ==
                                                false
                                            ? disable_your_account
                                            : activate_your_account,
                                        style: TextStyle(
                                            color: primarycolor,
                                            fontSize: 16.sp),
                                      );
                                    }),
                                    SizedBox(height: 0.02.sh),
                                    Obx(() {
                                      return Text(
                                        Get.find<AuthController>()
                                                    .usermodel
                                                    .value!
                                                    .accountDisabled ==
                                                false
                                            ? your_profile_account_shop_disabled
                                            : your_profile_account_shop_appear,
                                        style: TextStyle(
                                            color: primarycolor,
                                            fontSize: 14.sp),
                                      );
                                    }),
                                    SizedBox(height: 0.03.sh),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            Navigator.pop(dialogContext, false);

                                            deactivateProfile(context);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              yes,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              no,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.block,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      SizedBox(
                        width: 0.02.sh,
                      ),
                      Obx(() {
                        return Text(
                          Get.find<AuthController>()
                                      .usermodel
                                      .value!
                                      .accountDisabled ==
                                  false
                              ? disable_account
                              : activate_account,
                          style:
                              TextStyle(color: primarycolor, fontSize: 16.sp),
                        );
                      }),
                      const Spacer(),
                      const Icon(
                        Icons.navigate_next,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              Text(
                help,
                style: TextStyle(
                    fontSize: 18.0.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              _itemRow(
                "FAQ'S",
                () {},
                svg: "Question mark.svg",
              ),
              _itemRow(email_us, () {}, iconData: Icons.email),
              SizedBox(
                height: 0.02.sh,
              ),
              Text(
                legal,
                style: TextStyle(
                    fontSize: 18.0.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 0.02.sh,
              ),
              _itemRow(privacy_policy, () {}, iconData: Icons.lock),
              _itemRow(terms_onditions, () {}, iconData: Icons.note_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deactivateProfile(BuildContext context) async {
    bool toDisable = !authController.usermodel.value!.accountDisabled!;
    try {
      if (shopController.currentShop.value.id ==
          authController.usermodel.value!.shopId!.id) {
        authController.usermodel.value!.shopId!.open = !toDisable;
        shopController.currentShop.value.open = !toDisable;
        shopController.currentShop.refresh();

        authController.usermodel.refresh();
      }

      await BrandApi.updateShop(
          {"open": !toDisable}, authController.usermodel.value!.shopId!.id!);

      var response = UserAPI().updateUser(
          {"accountDisabled": toDisable}, authController.usermodel.value!.id!);

      await showDialog(
        context: context,
        builder: (context) {
          return AsyncProgressDialog(
            response,
            message: Text(
                toDisable == true ? disabling_account : activating_account,
                style: const TextStyle(color: Colors.black)),
            onError: (e) {},
          );
        },
      );
    } finally {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            toDisable == true
                ? account_disabled_successfully
                : account_enabled_successfully,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kPrimaryColor,
        ),
      );

      Get.find<AuthController>().usermodel.value!.accountDisabled = toDisable;
      Get.find<AuthController>().usermodel.refresh();

      shopController.currentShop.refresh();
    }
  }

  _itemRow(String title, Function function,
      {String? icon,
      IconData? iconData,
      String? svg,
      Color color = Colors.black}) {
    return Column(
      children: [
        SizedBox(
          height: 0.01.sh,
        ),
        InkWell(
          onTap: () => function(),
          child: Row(
            children: [
              if (svg != null)
                SvgPicture.asset(
                  "assets/icons/$svg",
                  width: 25,
                  color: color,
                ),
              if (icon != null)
                Image.asset(
                  "assets/icons/$icon",
                  width: 25,
                  color: color,
                ),
              if (iconData != null)
                Icon(
                  iconData,
                  color: color,
                ),
              SizedBox(
                width: 0.01.sh,
              ),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 14.sp),
              ),
              const Spacer(),
              const Icon(
                Icons.navigate_next,
                color: Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0.01.sh,
        ),
        const Divider(
          color: Colors.grey,
        ),
        SizedBox(
          height: 0.01.sh,
        ),
      ],
    );
  }
}
