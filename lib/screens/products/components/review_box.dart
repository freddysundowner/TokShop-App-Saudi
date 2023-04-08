import 'package:flutter/material.dart';
import 'package:tokshop/models/UserReview.dart';
import 'package:tokshop/widgets/product_image.dart';

import '../../../models/Review.dart';
import '../../../utils/utils.dart';

class ReviewBox extends StatelessWidget {
  final Review? productreview;
  final UserReview? userreview;
  ReviewBox({
    Key? key,
    this.productreview,
    this.userreview,
  }) : super(key: key);
  String feedback = "";
  int rating = 0;
  @override
  Widget build(BuildContext context) {
    if (userreview != null) {
      feedback = userreview!.feedback!;
      rating = userreview!.rating;
    }
    if (productreview != null) {
      feedback = productreview!.feedback!;
      rating = productreview!.rating;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: kTextColor.withOpacity(0.075),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userreview != null)
                  Row(
                    children: [
                      ProductImage(
                        element: userreview!.from!.firstName!.isNotEmpty
                            ? userreview!.from!.profilePhoto!
                            : "",
                        size: 15,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        userreview!.from!.firstName!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                Text(
                  feedback,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              Text(
                "${rating}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
