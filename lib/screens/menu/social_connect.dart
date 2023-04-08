import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/utils/text.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../models/user.dart';
import '../../services/user_api.dart';
import '../../utils/utils.dart';

class SocialMediaConnect extends StatelessWidget {
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

  SocialMediaConnect({Key? key}) : super(key: key);
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
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Styles.textButton.withOpacity(0.25)),
        child: Column(
          children: [
            InkWell(
              onTap: () => setSocialLink('twitter', context),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/twitter.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.03.sw,
                  ),
                  Text(
                    twitter,
                    style: TextStyle(color: primarycolor, fontSize: 16.sp),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withOpacity(0.30)),
                    child: const Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            InkWell(
              onTap: () => setSocialLink('instagram', context),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/instagram.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.03.sw,
                  ),
                  Text(
                    instagram,
                    style: TextStyle(fontSize: 18.0.sp, color: primarycolor),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withOpacity(0.30)),
                    child: const Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Styles.greenTheme.withOpacity(0.33)),
            InkWell(
              onTap: () => setSocialLink('facebook', context),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/facebook.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.03.sw,
                  ),
                  Text(
                    facebook,
                    style: TextStyle(fontSize: 18.0.sp, color: primarycolor),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withOpacity(0.30)),
                    child: const Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            InkWell(
              onTap: () => setSocialLink('linkedIn', context),
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/linkedin.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.03.sw,
                  ),
                  Text(
                      linkedIn,
                    style: TextStyle(fontSize: 18.0.sp, color: primarycolor),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryColor.withOpacity(0.30)),
                    child: const Icon(
                      Icons.navigate_next,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  setSocialLink(String type, BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )),
      builder: (context) {
        UserModel user = authController.usermodel.value!;

        if (user.twitter != null) {
          twitterController.text = user.twitter!;
        }
        if (user.linkedIn != null) {
          linkedInController.text = user.linkedIn!;
        }
        if (user.instagram != null) {
          instagramController.text = user.instagram!;
        }
        if (user.facebook != null) {
          facebookController.text = user.facebook!;
        }

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0),
              ),
            ),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: SvgPicture.asset(
                          "assets/icons/chevron_left.svg",
                          color: primarycolor,
                        ),
                      ),
                      Center(
                          child: Text(
                        type.capitalizeFirst!,
                        style: TextStyle(fontSize: 20.sp, color: primarycolor),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 0.03.sh,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            cursorColor: Colors.white,
                            controller: type == 'twitter'
                                ? twitterController
                                : type == 'instagram'
                                    ? instagramController
                                    : type == 'facebook'
                                        ? facebookController
                                        : linkedInController,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return please_enter_some_text;
                              } else {
                                var link = type == 'twitter'
                                    ? twitterController.text
                                    : type == 'instagram'
                                        ? instagramController.text
                                        : type == 'facebook'
                                            ? facebookController.text
                                            : linkedInController.text;
                                return validateLink(link, type);
                              }
                            },
                            decoration: InputDecoration(
                              filled: true,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: 'your $type account link ',
                              hintStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Styles.dullGreyColor),
                              errorText: socialLinkError,
                            ),
                            keyboardType: TextInputType.url,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 0.02.sh,
                  ),
                  InkWell(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        printOut("Validating 1");
                        var link = type == 'twitter'
                            ? twitterController.text
                            : type == 'instagram'
                                ? instagramController.text
                                : type == 'facebook'
                                    ? facebookController.text
                                    : linkedInController.text;

                        saveSocialAccount(type, link);
                      } else {
                        printOut("Validating 1");
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          save,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      )),
                    ),
                  ),
                  SizedBox(
                    height: 0.03.sh,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  saveSocialAccount(String type, link) async {
    var saved = await UserAPI()
        .updateUser({type: link}, FirebaseAuth.instance.currentUser!.uid);

    if (type == 'twitter') {
      authController.usermodel.value!.twitter = link;
    } else if (type == 'instagram') {
      authController.usermodel.value!.instagram = link;
    } else if (type == 'facebook') {
      authController.usermodel.value!.facebook = link;
    } else if (type == 'linkedIn') {
      authController.usermodel.value!.linkedIn = link;
    }

    printOut("User saved, $saved");
    Get.back();
  }

  String? validateLink(String link, String type) {
    String? socialLinkError;
    if (Uri.parse(link).host != '') {
      socialLinkError = null;
    } else {
      socialLinkError = link_not_correct;
    }

    return socialLinkError;
  }
}
