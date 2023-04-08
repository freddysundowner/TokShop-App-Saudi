import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/utils.dart';

class CustomActionBar extends StatelessWidget {
  final String title;
  final String qty;
  const CustomActionBar({
    Key? key,
    required this.title,
    required this.qty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        top: 56.0.sm,
        left: 24.0.sm,
        right: 24.0.sm,
        bottom: 42.0.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 42.0.w,
              height: 42.0.h,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.65),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: const Image(
                image: AssetImage("assets/images/back_arrow.png"),
                color: Colors.white,
                width: 16.0,
                height: 16.0,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sm),
              height: 42.0.sm,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.65),
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Text(
                "$qty: $qty",
                style: TextStyle(
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
