import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/utils/text.dart';

import 'controllers/auth_controller.dart';
import 'utils/styles.dart';
import 'widgets/widgets.dart';

class ConnectionFailed extends StatelessWidget {
  ConnectionFailed({Key? key}) : super(key: key);
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                connection_failed,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            DefaultButton(
                color: primarycolor,
                text: Refresh,
                press: () {
                  Get.offNamedUntil("/", (route) => false);
                })
          ],
        ),
      ),
    );
  }
}
