import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

//ignore: must_be_immutable
class AddAccountUserInfo extends StatelessWidget {
  final _formSingupKey = GlobalKey<FormState>();

  final AuthController authController = Get.put(AuthController());

  AddAccountUserInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          account_information,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formSingupKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10.0,
                              ),
                              TextFormField(
                                controller: authController.fnameFieldController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: full_names,
                                  border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(6.0)),
                                ),
                                validator: (value) {
                                  if (authController
                                      .fnameFieldController.text.isEmpty) {
                                    return "name is required";
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              SizedBox(height: 15.sp),
                              TextFormField(
                                controller:
                                    authController.usernameFieldController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: "Username",
                                  border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(6.0)),
                                ),
                                validator: (value) {
                                  if (authController
                                      .usernameFieldController.text.isEmpty) {
                                    return "username is required";
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              SizedBox(height: 67.sp),
                              DefaultButton(
                                text: "Save",
                                press: () async {
                                  Get.defaultDialog(
                                      title: "Creating account",
                                      contentPadding: const EdgeInsets.all(10),
                                      content:
                                          const CircularProgressIndicator(),
                                      barrierDismissible: false);
                                  await authController
                                      .loginRegisterSocial("apple");
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 17.h),
                      InkWell(
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(
                              "https://reggycodas.com/privacy-policy-3/"))) {
                            await launchUrl(Uri.parse(
                                "https://reggycodas.com/privacy-policy-3/"));
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 17),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                    text: "By signing up you accept our \n ",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: primarycolor,
                                        fontWeight: FontWeight.w400)),
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: primarycolor,
                                      fontSize: 14.0,
                                      decoration: TextDecoration.underline),
                                ),
                                TextSpan(
                                    text: " and ",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: primarycolor,
                                        fontWeight: FontWeight.w400)),
                                TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: primarycolor,
                                        fontSize: 14.0,
                                        decoration: TextDecoration.underline)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
