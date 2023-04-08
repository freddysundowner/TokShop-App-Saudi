import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SizeConfig {
  static final MediaQueryData _mediaQueryData = MediaQuery.of(Get.context!);
  static double? screenWidth = _mediaQueryData.size.width;
  static double? screenHeight = _mediaQueryData.size.height;
  static double? defaultSize;
  static Orientation? orientation = _mediaQueryData.orientation;
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double? screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight!;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double? screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth!;
}
