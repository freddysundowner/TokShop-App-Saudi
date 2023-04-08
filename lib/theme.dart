import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/utils.dart';

ThemeData theme() {
  return ThemeData(
    primaryColor: primarycolor,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    backgroundColor: Colors.white,
    bottomAppBarColor: Colors.grey[50],
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Circular",
    appBarTheme: appBarTheme(),
    textTheme: textTheme(),
    inputDecorationTheme: inputDecorationTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Colors.black,
      contentTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),
  );
}

InputDecorationTheme inputDecorationTheme() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: primarycolor),
    gapPadding: 5,
  );
  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
  );
}

TextTheme textTheme() {
  return const TextTheme(
    bodyText1: TextStyle(
        fontSize: 16, fontFamily: "Circular", fontWeight: FontWeight.bold),
    bodyText2: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
  );
}

AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 1,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    iconTheme: IconThemeData(color: primarycolor),
    toolbarTextStyle: TextStyle(color: primarycolor, fontSize: 18),
    titleTextStyle: TextStyle(color: primarycolor, fontSize: 18),
    centerTitle: false,
  );
}
