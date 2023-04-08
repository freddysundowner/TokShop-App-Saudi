import 'package:flutter/material.dart';
import 'package:tokshop/utils/styles.dart';

class CustomTitle extends StatelessWidget {
  String? linktext;
  String? title;
  Function? callBackFunction;
  IconData? iconData;
  CustomTitle(
      {Key? key,
      this.linktext = "",
      this.title,
      this.callBackFunction,
      this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  if (iconData != null)
                    Icon(
                      iconData!,
                      size: 21,
                    )
                ],
              ),
              if (linktext!.isNotEmpty)
                InkWell(
                  onTap: () {
                    callBackFunction!();
                  },
                  child: Text(
                    linktext!,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: primarycolor, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
