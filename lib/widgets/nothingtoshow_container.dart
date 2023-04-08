import 'package:flutter/material.dart';

import '../utils/utils.dart';

class NothingToShowContainer extends StatelessWidget {
  final String? iconPath;
  final String primaryMessage;
  final String secondaryMessage;
  final Widget? widget;

  const NothingToShowContainer({
    Key? key,
    this.widget,
    this.iconPath,
    this.primaryMessage = "",
    this.secondaryMessage = "",
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            primaryMessage,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          Center(
            child: iconPath != null
                ? Image.asset(iconPath!)
                : const Icon(
                    Icons.search_off,
                    size: 80,
                    color: primarycolor,
                  ),
          ),
          Text(
            secondaryMessage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget != null)
            Container(
              child: widget,
            )
        ],
      ),
    );
  }
}
