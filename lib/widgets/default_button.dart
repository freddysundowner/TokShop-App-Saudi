import 'package:flutter/material.dart';

import '../utils/utils.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final double? textSize;
  final Function press;
  final Color txtcolor;
  final Color color;
  final Color bordercolor;
  final double radius;
  const DefaultButton({
    Key? key,
    required this.text,
    required this.press,
    this.textSize = 16,
    this.radius = 8,
    this.txtcolor = Colors.white,
    this.color = kPrimaryColor,
    this.bordercolor = kPrimaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => press(),
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: bordercolor)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            text,
            style: TextStyle(
                fontSize: textSize,
                color: txtcolor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
