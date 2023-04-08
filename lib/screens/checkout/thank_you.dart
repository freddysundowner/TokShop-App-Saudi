import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/screens/home/home_page.dart';
import 'package:tokshop/screens/home/main_page.dart';
import 'package:tokshop/screens/orders/order_receipt.dart';
import 'package:tokshop/utils/styles.dart';

import '../../utils/text.dart';

class ThankYouPage extends StatelessWidget {
  Order? order;
  ThankYouPage({Key? key, this.order}) : super(key: key);

  double screenWidth = 600;
  double screenHeight = 400;
  Color textColor = const Color(0xFF32567A);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 170,
              padding: EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/icons/card.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            Text(
              "$thank_you!",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 36,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            const Text(order_completed),
            SizedBox(height: screenHeight * 0.05),
            InkWell(
              onTap: () {
                Get.to(() => OrderReceipt(order!));
              },
              child: const Text(
                view_order_receipt,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            InkWell(
              onTap: () {
                Get.offAll(() => MainPage());
              },
              child: const Text(
                "<< $back_to_home",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
