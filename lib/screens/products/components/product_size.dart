import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/checkout_controller.dart';
import '../../../utils/utils.dart';

class ProductSize extends StatelessWidget {
  final List productSizes;
  final Function(String) onSelected;
  final CheckOutController checkOutController = Get.find<CheckOutController>();
  ProductSize({Key? key, required this.productSizes, required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.05.sh,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: productSizes.length,
          itemBuilder: (context, index) {
            var i = index;
            return GestureDetector(
              onTap: () {
                onSelected("${productSizes[i]}");
                checkOutController.selectetedvariation.value = i;
              },
              child: Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border:
                            checkOutController.selectetedvariation.value == i
                                ? null
                                : Border.all(color: Colors.grey),
                        color: checkOutController.selectetedvariation.value == i
                            ? kPrimaryColor
                            : Colors.transparent),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                    ),
                    child: Text(
                      "${productSizes[i]}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: checkOutController.selectetedvariation.value == i
                            ? Colors.white
                            : Colors.black,
                        fontSize: 14.0.sp,
                      ),
                    ),
                  )),
            );
          }),
    );
  }
}
