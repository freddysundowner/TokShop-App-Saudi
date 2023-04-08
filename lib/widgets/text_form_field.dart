import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/utils.dart';

class CustomTextFormField extends StatelessWidget {
  TextEditingController? controller;
  String? hint;
  bool? validate;
  Function? onChanged;
  String? label;
  Color? txtColor;
  Widget? suffix;
  TextInputType? txtType;
  Widget? prefix;
  CustomTextFormField(
      {Key? key,
      this.controller,
      this.onChanged,
      this.suffix,
      this.txtType = TextInputType.text,
      this.prefix,
      this.txtColor = primarycolor,
      this.hint,
      this.validate = false,
      this.label = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label!.isNotEmpty)
          SizedBox(
            height: 0.015.sh,
          ),
        if (label!.isNotEmpty)
          Text(
            label!,
            style: TextStyle(color: primarycolor, fontSize: 14.sp),
          ),
        if (label!.isNotEmpty)
          SizedBox(
            height: 0.01.sh,
          ),
        TextFormField(
          scrollPadding: const EdgeInsets.all(0),
          keyboardType: txtType,
          validator: validate == false
              ? null
              : (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field required';
                  }
                  return null;
                },
          controller: controller,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          onChanged: (data) => onChanged!(data),
          minLines: 1,
          autofocus: false,
          decoration: InputDecoration(
            suffix: suffix != null ? suffix! : null,
            prefix: prefix != null ? prefix! : null,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          style: TextStyle(color: txtColor, fontSize: 14.sp),
        ),
      ],
    );
  }
}
