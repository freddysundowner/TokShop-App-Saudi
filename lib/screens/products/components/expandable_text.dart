import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/utils.dart';

class ExpandableText extends StatelessWidget {
  final String title;
  final String content;
  final int maxLines;
  const ExpandableText({
    Key? key,
    required this.title,
    required this.content,
    this.maxLines = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const Divider(
          height: 8,
          thickness: 1,
          endIndent: 16,
        ),
        Text(
          content,
          maxLines: maxLines,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 16.sp),
        ),
      ],
    );
  }
}
