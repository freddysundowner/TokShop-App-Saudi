import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/text.dart';
import '../utils/utils.dart';

class FollowUnfollowButton extends StatelessWidget {
  Function callBack;
  bool enabled;
  double? width;
  double? textSize;
  double? height;
  Color? bgColor;

  FollowUnfollowButton(
      {Key? key,
      required this.callBack,
      required this.enabled,
      this.bgColor,
      this.width,
      this.textSize = 12,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        callBack();
      },
      child: Container(
        width: width ?? 0.25.sw,
        height: height ?? 0.034.sh,
        decoration: BoxDecoration(
            color: bgColor ?? (enabled ? primarycolor : kPrimaryColor),
            border: Border.all(color: enabled ? primarycolor : kPrimaryColor),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            !enabled ? following : follow,
            style: TextStyle(color: Colors.white, fontSize: textSize),
          ),
        ),
      ),
    );
  }
}
