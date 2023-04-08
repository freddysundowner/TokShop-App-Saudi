import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tokshop/main.dart';

import '../../utils/styles.dart';
import '../../utils/text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 43.0,
          bottom: 26.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              "assets/images/logo.png",
              width: 160,
              color: primarycolor,
            ),
            const Text(
              tok_shop,
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: primarycolor),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                shop_live,
                style:
                    TextStyle(fontSize: 26, height: 1.5, color: primarycolor),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Obx(() => authController.supportsAppleSignIn.isTrue
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30.0),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: SignInWithAppleButton(
                      style: SignInWithAppleButtonStyle.whiteOutlined,
                      iconAlignment: IconAlignment.center,
                      height: 53,
                      onPressed: () async {
                        Get.defaultDialog(
                            title: sign_with_apple,
                            contentPadding: const EdgeInsets.all(10),
                            content: const CircularProgressIndicator(),
                            barrierDismissible: false);
                        await authController.signInWithApple();
                        Get.back();
                      },
                    ),
                  )
                : Container()),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                Get.defaultDialog(
                    title: sign_with_google,
                    contentPadding: const EdgeInsets.all(10),
                    content: const CircularProgressIndicator(),
                    barrierDismissible: false);
                await authController.signInWithGoogle();
                Get.back();
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(
                    horizontal: Platform.isAndroid ? 50 : 60, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage("assets/icons/google.png"),
                      height: 18.0,
                      width: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 5),
                      child: Text(
                        signn_with_google,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: primarycolor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(
            //   height: 30,
            // ),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     primary: const Color(0Xff3a5997),
            //     onPrimary: Colors.black,
            //   ),
            //   onPressed: () async {
            //     Get.defaultDialog(
            //         title: "Signing in with faceboook",
            //         contentPadding: const EdgeInsets.all(10),
            //         content: const CircularProgressIndicator(),
            //         barrierDismissible: false);
            //     await authController.signInWithFacebook();
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: const [
            //         Image(
            //           image: AssetImage("assets/icons/fb.png"),
            //           height: 30.0,
            //           width: 24,
            //         ),
            //         Padding(
            //           padding:
            //               EdgeInsets.symmetric(horizontal: 50.0, vertical: 5),
            //           child: Text(
            //             'Sign in with Facebook',
            //             style: TextStyle(
            //               fontSize: 20,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class Item {
  static final random = Random();
  double? _size;
  Color? _color;

  Alignment? _alignment;

  Item() {
    _color = Color.fromARGB(random.nextInt(255), random.nextInt(255),
        random.nextInt(255), random.nextInt(255));
    _alignment =
        Alignment(random.nextDouble() * 4 - 1, random.nextDouble() * 2 - 1);
    _size = 60;
  }
}
